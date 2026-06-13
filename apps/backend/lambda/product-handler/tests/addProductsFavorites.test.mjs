import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/databases/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/databases/productDatabase.mjs', () => ({
    getLatestProductFromDB: vi.fn()
}));

vi.mock('../services/databases/productsFavoritesDatabase.mjs', () => ({
    getFavorite: vi.fn(),
    addFavorite: vi.fn(),
    removeFavorite: vi.fn()
}));

vi.mock('../helpers/validation/barcode.mjs', () => ({
    normalizeBarcode: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { addProductsFavorites } from '../handlers/addProductsFavorites.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { getLatestProductFromDB } from '../services/databases/productDatabase.mjs';
import { getFavorite, addFavorite, removeFavorite } from '../services/databases/productsFavoritesDatabase.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';

const makeEvent = (barcode) => ({
    pathParameters: { barcode },
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('addProductsFavorites', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
        normalizeBarcode.mockReturnValue('1234567890');
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await addProductsFavorites(makeEvent('1234567890'));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Unauthorized' });
        });
    });

    describe('invalid barcode', () => {

        it('should return 400 if barcode is invalid', async () => {
            normalizeBarcode.mockReturnValue(null);

            const result = await addProductsFavorites(makeEvent('not-real-barcode'));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid barcode' });
        });
    });

    describe('toggle favorite', () => {

        it('should remove favorite and return liked=false if already in favorites', async () => {
            getFavorite.mockResolvedValue({ userId: 'user-123', barcode: '1234567890' });

            const result = await addProductsFavorites(makeEvent('1234567890'));

            expect(removeFavorite).toHaveBeenCalledWith('user-123', '1234567890');
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ liked: false });
        });

        it('should return 404 if product not in DB when adding like', async () => {
            getFavorite.mockResolvedValue(null);
            getLatestProductFromDB.mockResolvedValue(null);

            const result = await addProductsFavorites(makeEvent('1234567890'));

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Product not found in database' });
        });

        it('should add favorite and return liked=true if not in favorites and product exists', async () => {
            const fakeProduct = { barcode: '1234567890', product_name: 'Test', brands: 'Brand', image_url: null, updated_at: 1 };
            getFavorite.mockResolvedValue(null);
            getLatestProductFromDB.mockResolvedValue(fakeProduct);
            addFavorite.mockResolvedValue({});

            const result = await addProductsFavorites(makeEvent('1234567890'));

            expect(addFavorite).toHaveBeenCalledWith('user-123', fakeProduct);
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ liked: true });
        });
    });
});
