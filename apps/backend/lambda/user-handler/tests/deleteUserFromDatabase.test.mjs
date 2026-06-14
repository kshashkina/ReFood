import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserByCognitoSub: vi.fn(),
    deleteUser: vi.fn()
}));

vi.mock('../services/scansDatabase.mjs', () => ({
    deleteAllUserScans: vi.fn()
}));

vi.mock('../services/productsFavoritesDatabase.mjs', () => ({
    deleteAllUserFavorites: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetrics: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { deleteUserData } from '../handlers/deleteUserFromDatabase.mjs';
import { findUserByCognitoSub, deleteUser } from '../services/usersDatabase.mjs';
import { deleteAllUserScans } from '../services/scansDatabase.mjs';
import { deleteAllUserFavorites } from '../services/productsFavoritesDatabase.mjs';
import { invokeMetrics } from '../services/metricsService.mjs';

const makeEvent = (claims = { sub: 'cognito-sub-123' }) => ({
    requestContext: { authorizer: { claims } },
    headers: {}
});

describe('deleteUserData', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        deleteAllUserScans.mockResolvedValue({});
        deleteUser.mockResolvedValue({});
        deleteAllUserFavorites.mockResolvedValue({});
    });

    describe('unauthorized', () => {

        it('should return 401 if cognitoSub is missing', async () => {
            const result = await deleteUserData(makeEvent(null));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Authorization required' });
        });
    });

    describe('user not found', () => {

        it('should return 404 if user is not found by cognitoSub', async () => {
            findUserByCognitoSub.mockResolvedValue(null);

            const result = await deleteUserData(makeEvent());

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not found' });
        });
    });

    describe('successful deletion', () => {

        it('should delete scans, user, favorites and invoke metrics', async () => {
            findUserByCognitoSub.mockResolvedValue({ userId: 'user-123' });

            const result = await deleteUserData(makeEvent());

            expect(deleteAllUserScans).toHaveBeenCalledWith('user-123');
            expect(deleteUser).toHaveBeenCalledWith('user-123');
            expect(deleteAllUserFavorites).toHaveBeenCalledWith('user-123');
            expect(invokeMetrics).toHaveBeenCalledWith('delete_metrics', 'user-123');
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'All user data deleted' });
        });
    });

    describe('error handling', () => {

        it('should return 500 if DB throws', async () => {
            findUserByCognitoSub.mockRejectedValue(new Error('DB unavailable'));

            const result = await deleteUserData(makeEvent());

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to delete account' });
        });
    });
});
