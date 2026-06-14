import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/validation/barcode.mjs', () => ({
    normalizeBarcode: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

vi.mock('../services/databases/productDatabase.mjs', () => ({
    getLatestProductFromDB: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    compareProducts: vi.fn()
}));

import { getCompareProducts } from '../handlers/getCompareProducts.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { getLatestProductFromDB } from '../services/databases/productDatabase.mjs';
import { compareProducts } from '../services/aiService.mjs';

const makeEvent = (barcodeA, barcodeB) => ({
    queryStringParameters: { barcodeA, barcodeB }
});

describe('getCompareProducts', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('invalid barcodes', () => {

        it('should return 400 if one barcode is invalid', async () => {
            normalizeBarcode.mockReturnValueOnce(null).mockReturnValueOnce('1234567890124');

            const result = await getCompareProducts(makeEvent('not-real-barcode', '1234567890124'));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Both barcodeA and barcodeB query parameters are required' });
        });

        it('should return 400 if both barcodes are missing', async () => {
            normalizeBarcode.mockReturnValue(null);

            const result = await getCompareProducts(makeEvent(undefined, undefined));

            expect(result.statusCode).toBe(400);
        });
    });

    describe('products not found in DB', () => {

        it('should return 404 if one of the products is not in DB', async () => {
            normalizeBarcode.mockReturnValueOnce('1234567890').mockReturnValueOnce('1234567889');
            getLatestProductFromDB.mockResolvedValueOnce(null).mockResolvedValueOnce({ barcode: '1234567889' });

            const result = await getCompareProducts(makeEvent('1234567890', '1234567889'));

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'One or both products not found. Please scan them first.' });
        });

        it('should return 404 if both products are not in DB', async () => {
            normalizeBarcode.mockReturnValueOnce('1234567890').mockReturnValueOnce('1234567889');
            getLatestProductFromDB.mockResolvedValue(null);

            const result = await getCompareProducts(makeEvent('1234567890', '1234567889'));

            expect(result.statusCode).toBe(404);
        });
    });

    describe('successful comparison', () => {

        it('should return 200 with analysis from AI', async () => {
            normalizeBarcode.mockReturnValueOnce('1234567890').mockReturnValueOnce('1234567889');

            const productA = { barcode: '1234567890', product_name: 'A' };
            const productB = { barcode: '1234567889', product_name: 'B' };

            getLatestProductFromDB.mockResolvedValueOnce(productA).mockResolvedValueOnce(productB);
            compareProducts.mockResolvedValue({ winner: 'A', explanation: 'Better score' });

            const result = await getCompareProducts(makeEvent('1234567890', '1234567889'));

            expect(compareProducts).toHaveBeenCalledWith(productA, productB);
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ analysis: { winner: 'A' } });
        });
    });

    describe('error handling', () => {

        it('should return 500 if compareProducts throws', async () => {
            normalizeBarcode.mockReturnValueOnce('1234567890').mockReturnValueOnce('1234567889');
            getLatestProductFromDB.mockResolvedValue({ barcode: 'any' });
            compareProducts.mockRejectedValue(new Error('AI unavailable'));

            const result = await getCompareProducts(makeEvent('1234567890', '1234567889'));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to compare products' });
        });
    });
});
