import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/databases/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/databases/productsFavoritesDatabase.mjs', () => ({
    removeFavorite: vi.fn()
}));

vi.mock('../helpers/validation/barcode.mjs', () => ({
    normalizeBarcode: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { removeProductFromFavorites } from '../handlers/removeProductFromFavorites.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { removeFavorite } from '../services/databases/productsFavoritesDatabase.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';

const makeEvent = (barcode) => ({
    pathParameters: { barcode },
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('removeProductFromFavorites', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
        normalizeBarcode.mockReturnValue('1234567890');
        removeFavorite.mockResolvedValue({});
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await removeProductFromFavorites(makeEvent('1234567890'));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Unauthorized' });
        });
    });

    describe('invalid barcode', () => {

        it('should return 400 if barcode is invalid', async () => {
            normalizeBarcode.mockReturnValue(null);

            const result = await removeProductFromFavorites(makeEvent('not-real-barcode'));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid barcode' });
        });
    });

    describe('successful removal', () => {

        it('should call removeFavorite with correct userId and barcode', async () => {
            const result = await removeProductFromFavorites(makeEvent('1234567890'));

            expect(removeFavorite).toHaveBeenCalledWith('user-123', '1234567890');
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ liked: false });
        });
    });
});
