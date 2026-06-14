import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/validation/barcode.mjs', () => ({
    normalizeBarcode: vi.fn()
}));

vi.mock('../helpers/validation/validator.mjs', () => ({
    validateProductInput: vi.fn()
}));

vi.mock('../helpers/formatters/cleanProductData.mjs', () => ({
    cleanProductData: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    checkProduct: vi.fn(),
    translateProduct: vi.fn()
}));

vi.mock('../services/s3Service.mjs', () => ({
    finalizeImage: vi.fn()
}));

vi.mock('../services/databases/productDatabase.mjs', () => ({
    saveProductToDB: vi.fn()
}));

vi.mock('../services/databases/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetrics: vi.fn()
}));

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { createProduct } from '../handlers/createProduct.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { validateProductInput } from '../helpers/validation/validator.mjs';
import { cleanProductData } from '../helpers/formatters/cleanProductData.mjs';
import { checkProduct, translateProduct } from '../services/aiService.mjs';
import { finalizeImage } from '../services/s3Service.mjs';
import { saveProductToDB } from '../services/databases/productDatabase.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';

const makeEvent = (body = {}, overrides = {}) => ({
    body: JSON.stringify(body),
    requestContext: { authorizer: null, identity: null },
    headers: {},
    ...overrides
});

const validBody = {
    barcode: '1234567890123',
    product_name: 'Test',
    ingredients_text: 'sugar, water',
    nutriments: { energy_kcal_100g: 100 }
};

const cleanedData = {
    product_name: 'Test',
    ingredients_text: 'sugar, water',
    nutriments: { energy_kcal_100g: 100 },
    image_url: null
};

describe('createProduct', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        validateProductInput.mockReturnValue({ valid: true, errors: [] });
        normalizeBarcode.mockReturnValue('1234567890');
        cleanProductData.mockReturnValue(cleanedData);
        checkProduct.mockResolvedValue({ canBeSaved: true });
        translateProduct.mockResolvedValue({ categories_tags_ua: 'снеки' });
        saveProductToDB.mockResolvedValue({});
        getRequestIdentity.mockReturnValue(null);
        findUserIdByAnyMethod.mockResolvedValue(null);
    });

    describe('invalid request body', () => {

        it('should return 400 for invalid JSON body', async () => {
            const result = await createProduct({ body: '{invalid json}', requestContext: {}, headers: {} });

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid JSON body' });
        });

        it('should return 400 if validation fails', async () => {
            validateProductInput.mockReturnValue({ valid: false, errors: ['barcode is required'] });

            const result = await createProduct(makeEvent(validBody));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Validation failed' });
        });

        it('should return 400 if barcode is invalid after normalization', async () => {
            normalizeBarcode.mockReturnValue(null);

            const result = await createProduct(makeEvent(validBody));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid barcode format' });
        });
    });

    describe('image finalization', () => {

        it('should return 400 if image finalization fails', async () => {
            finalizeImage.mockResolvedValue({ success: false, code: 'REJECTED', message: 'Not a product' });

            const bodyWithImage = { ...validBody, imageId: 'img-001', s3Key: 'temp/img-001.jpg' };
            const result = await createProduct(makeEvent(bodyWithImage));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Image finalization failed' });
        });

        it('should finalize image and use publicUrl', async () => {
            finalizeImage.mockResolvedValue({ success: true, publicUrl: 'https://cdn.example.com/img.jpg' });

            const bodyWithImage = { ...validBody, imageId: 'img-001', s3Key: 'temp/img-001.jpg' };
            const result = await createProduct(makeEvent(bodyWithImage));

            expect(finalizeImage).toHaveBeenCalledWith({
                s3Key: 'temp/img-001.jpg',
                imageId: 'img-001',
                barcode: '1234567890'
            });
            expect(result.statusCode).toBe(201);
        });

        it('should skip image finalization if imageId or s3Key is absent', async () => {
            const result = await createProduct(makeEvent(validBody));

            expect(finalizeImage).not.toHaveBeenCalled();
            expect(result.statusCode).toBe(201);
        });
    });

    describe('successful creation', () => {

        it('should return 201 with success message', async () => {
            const result = await createProduct(makeEvent(validBody));

            expect(result.statusCode).toBe(201);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'Product verified and created successfully' });
        });
    });

    describe('error handling', () => {

        it('should return 500 if AI service throws', async () => {
            checkProduct.mockRejectedValue(new Error('AI unavailable'));

            const result = await createProduct(makeEvent(validBody));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to process product with AI services' });
        });

        it('should return 500 if saveProductToDB throws', async () => {
            saveProductToDB.mockRejectedValue(new Error('DynamoDB unavailable'));

            const result = await createProduct(makeEvent(validBody));

            expect(result.statusCode).toBe(500);
        });
    });
});
