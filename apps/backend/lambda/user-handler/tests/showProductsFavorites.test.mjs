import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/productsFavoritesDatabase.mjs', () => ({
    getUserFavorites: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { showProductsFavorites } from '../handlers/showProductsFavorites.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getUserFavorites } from '../services/productsFavoritesDatabase.mjs';

const makeEvent = (query = {}) => ({
    queryStringParameters: query,
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('showProductsFavorites', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
        getUserFavorites.mockResolvedValue({ items: [], lastKey: null });
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await showProductsFavorites(makeEvent());

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Unauthorized' });
        });
    });

    describe('successful favorites list', () => {

        it('should return 200 with favorites array', async () => {
            const fakeItems = [{ userId: 'user-123', barcode: '1234567890', product_name: 'Milk' }];
            getUserFavorites.mockResolvedValue({ items: fakeItems, lastKey: null });

            const result = await showProductsFavorites(makeEvent());

            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.favorites).toHaveLength(1);
        });
    });
});
