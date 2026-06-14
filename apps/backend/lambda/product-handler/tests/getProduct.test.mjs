import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/databases/productDatabase.mjs', () => ({
    getLatestProductFromDB: vi.fn(),
    saveProductToDB: vi.fn()
}));

vi.mock('../services/fetchOffApi.mjs', () => ({
    fetchFromOpenFoodFacts: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    translateProduct: vi.fn()
}));

vi.mock('../mappers/productMapper.mjs', () => ({
    toProductResponse: vi.fn()
}));

vi.mock('../helpers/validation/barcode.mjs', () => ({
    normalizeBarcode: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { getProduct } from '../handlers/getProduct.mjs';
import { getLatestProductFromDB, saveProductToDB } from '../services/databases/productDatabase.mjs';
import { fetchFromOpenFoodFacts } from '../services/fetchOffApi.mjs';
import { translateProduct } from '../services/aiService.mjs';
import { toProductResponse } from '../mappers/productMapper.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';

const makeEvent = (barcode) => ({
    pathParameters: { barcode }
});

const fakeOffProduct = {
    barcode: '1234567890',
    product_name: 'OFF Product',
    categories_tags: 'snacks',
    allergens_tags: 'gluten',
    ingredients_text: 'sugar',
    packaging: [],
    image_url: 'http://example.com/image.jpg',
    image_thumb_url: 'http://example.com/image-thumb.jpg'
};

describe('getProduct', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('invalid barcode', () => {

        it('should return 400 if barcode is invalid', async () => {
            normalizeBarcode.mockReturnValue(null);

            const result = await getProduct(makeEvent('not-real-barcode'));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid barcode format' });
        });
    });

    describe('product found in DB', () => {

        it('should return 200 with source "local" if product is in DB', async () => {
            normalizeBarcode.mockReturnValue('1234567890');
            const fakeProduct = { barcode: '1234567890', product_name: 'DB Product' };
            getLatestProductFromDB.mockResolvedValue(fakeProduct);

            const result = await getProduct(makeEvent('1234567890'));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ source: 'local', product: fakeProduct });
        });

        it('should not call OFF API if product is in DB', async () => {
            normalizeBarcode.mockReturnValue('1234567890');
            getLatestProductFromDB.mockResolvedValue({ barcode: '1234567890' });

            await getProduct(makeEvent('1234567890'));

            expect(fetchFromOpenFoodFacts).not.toHaveBeenCalled();
        });
    });

    describe('when product not in DB, search using OFF API and save it', () => {

        it('should return 404 if OFF API returns null', async () => {
            normalizeBarcode.mockReturnValue('1234567890');
            getLatestProductFromDB.mockResolvedValue(null);
            fetchFromOpenFoodFacts.mockResolvedValue(null);

            const result = await getProduct(makeEvent('1234567890'));

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Product not found' });
        });

        it('should translate, save and return 200', async () => {
            normalizeBarcode.mockReturnValue('1234567890');
            getLatestProductFromDB.mockResolvedValue(null)

            fetchFromOpenFoodFacts.mockResolvedValue(fakeOffProduct);
            translateProduct.mockResolvedValue({ categories_tags_ua: 'снеки', ingredients_text: 'цукор' });
            saveProductToDB.mockResolvedValue({});
            toProductResponse.mockReturnValue({ product_name: 'OFF Product', ingredients_text: 'цукор', image_url: 'http://example.com/image.jpg' });

            const result = await getProduct(makeEvent('1234567890'));

            expect(translateProduct).toHaveBeenCalled();
            expect(saveProductToDB).toHaveBeenCalled();
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ source: 'openfoodfacts' });
        });
    });
});
