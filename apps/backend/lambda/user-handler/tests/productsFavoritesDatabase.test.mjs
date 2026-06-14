import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSend } = vi.hoisted(() => ({
    mockSend: vi.fn()
}));

vi.mock('@aws-sdk/client-dynamodb', () => ({
    DynamoDBClient: function () { }
}));

vi.mock('@aws-sdk/lib-dynamodb', () => ({
    DynamoDBDocumentClient: {
        from: vi.fn().mockReturnValue({ send: mockSend })
    },
    QueryCommand: function (input) { this.input = input; },
    DeleteCommand: function (input) { this.input = input; }
}));

import { getUserFavorites, deleteAllUserFavorites } from '../services/productsFavoritesDatabase.mjs';

describe('productsFavoritesDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getUserFavorites', () => {

        it('should return items and null lastKey if no more pages', async () => {
            const fakeItems = [{ userId: 'user-123', barcode: '1234567890' }];
            mockSend.mockResolvedValue({ Items: fakeItems, LastEvaluatedKey: undefined });

            const result = await getUserFavorites('user-123');

            expect(result.items).toEqual(fakeItems);
            expect(result.lastKey).toBeNull();
        });

        it('should return empty items array if no favorites', async () => {
            mockSend.mockResolvedValue({ Items: [], LastEvaluatedKey: undefined });

            const result = await getUserFavorites('user-123');

            expect(result.items).toEqual([]);
        });

        it('should return lastKey if there are more pages', async () => {
            const lastKey = { userId: 'user-123', barcode: '1234567890' };
            mockSend.mockResolvedValue({ Items: [], LastEvaluatedKey: lastKey });

            const result = await getUserFavorites('user-123');

            expect(result.lastKey).toEqual(lastKey);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getUserFavorites('user-123')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('deleteAllUserFavorites', () => {

        it('should do nothing if user has no favorites', async () => {
            mockSend.mockResolvedValue({ Items: [], LastEvaluatedKey: undefined });

            await deleteAllUserFavorites('user-123');

            expect(mockSend).toHaveBeenCalledTimes(1);
        });

        it('should delete all favorites for a user', async () => {
            mockSend.mockResolvedValueOnce({
                Items: [
                    { userId: 'user-123', barcode: '1234567890' },
                    { userId: 'user-123', barcode: '1234567889' }
                ],
                LastEvaluatedKey: undefined
            }).mockResolvedValue({});

            await deleteAllUserFavorites('user-123');

            expect(mockSend).toHaveBeenCalledTimes(3);
        });
    });
});
