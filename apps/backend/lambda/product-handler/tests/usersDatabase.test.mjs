import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSendToDb } = vi.hoisted(() => ({
    mockSendToDb: vi.fn()
}));

vi.mock('@aws-sdk/client-dynamodb', () => ({
    DynamoDBClient: function () { }
}));

vi.mock('@aws-sdk/lib-dynamodb', () => ({
    DynamoDBDocumentClient: {
        from: vi.fn().mockReturnValue({ send: mockSendToDb })
    },
    UpdateCommand: function (input) { this.input = input; },
    QueryCommand: function (input) { this.input = input; }
}));

import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';

describe('usersDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('findUserIdByAnyMethod', () => {

        it('should return null if identity is null', async () => {
            const result = await findUserIdByAnyMethod(null);
            expect(result).toBeNull();
        });

        it('should return userId if user found by identityId', async () => {
            mockSendToDb.mockResolvedValue({ Items: [{ userId: 'user-123' }] });

            const result = await findUserIdByAnyMethod({ type: 'identity', id: 'identity-123' });

            expect(result).toBe('user-123');
        });

        it('should return userId if user found by jwt (cognitoSub)', async () => {
            mockSendToDb.mockResolvedValue({ Items: [{ userId: 'user-123' }] });

            const result = await findUserIdByAnyMethod({ type: 'jwt', id: 'cognito-sub-xyz' });

            expect(result).toBe('user-123');
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(findUserIdByAnyMethod({ type: 'identity', id: 'user-123' })).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
