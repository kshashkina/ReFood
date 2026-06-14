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
    GetCommand: function (input) { this.input = input; },
    QueryCommand: function (input) { this.input = input; },
    PutCommand: function (input) { this.input = input; },
    UpdateCommand: function (input) { this.input = input; },
    DeleteCommand: function (input) { this.input = input; }
}));

import { findUserIdByAnyMethod, findUserByDevice, createUser, updateIdentityId, getUserProfile, findUserByCognitoSub, linkUserToApple, updateUserDevice, deleteUser } from '../services/usersDatabase.mjs';

describe('usersDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('findUserIdByAnyMethod', () => {

        it('should return null if identity is null', async () => {
            const result = await findUserIdByAnyMethod(null);
            expect(result).toBeNull();
        });

        it('should return userId if found by identityId', async () => {
            mockSend.mockResolvedValue({ Items: [{ userId: 'user-123' }] });

            const result = await findUserIdByAnyMethod({ type: 'identity', id: 'id-abc' });

            expect(result).toBe('user-123');
        });

        it('should return userId if found by jwt', async () => {
            mockSend.mockResolvedValue({ Items: [{ userId: 'user-jwt-123' }] });

            const result = await findUserIdByAnyMethod({ type: 'jwt', id: 'cognito-sub' });

            expect(result).toBe('user-jwt-123');
        });

        it('should return null if no users found', async () => {
            mockSend.mockResolvedValue({ Items: [] });

            const result = await findUserIdByAnyMethod({ type: 'identity', id: 'unknown' });

            expect(result).toBeNull();
        });


        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(findUserIdByAnyMethod({ type: 'identity', id: 'not-real-id' })).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('findUserByDevice', () => {

        it('should return user if found by deviceId', async () => {
            const fakeUser = { userId: 'user-123', deviceId: 'device-abc' };
            mockSend.mockResolvedValue({ Items: [fakeUser] });

            const result = await findUserByDevice('device-abc');

            expect(result).toEqual(fakeUser);
        });

        it('should return null if no user found', async () => {
            mockSend.mockResolvedValue({ Items: [] });

            const result = await findUserByDevice('device-unknown');

            expect(result).toBeNull();
        });
    });

    describe('createUser', () => {

        it('should call PutCommand with user item', async () => {
            mockSend.mockResolvedValue({});
            const user = { userId: 'user-123', deviceId: 'device-abc', identityId: 'id-xyz' };

            await createUser(user);

            const calledWith = mockSend.mock.calls[0][0];
            expect(calledWith.input.Item).toEqual(user);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(createUser({ userId: 'user-123' })).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('updateIdentityId', () => {

        it('should call UpdateCommand with correct userId and new identityId', async () => {
            mockSend.mockResolvedValue({});
            await updateIdentityId('user-123', 'new-identity-id');

            const calledWith = mockSend.mock.calls[0][0];

            expect(calledWith.input.Key.userId).toBe('user-123');
            expect(calledWith.input.ExpressionAttributeValues[':i']).toBe('new-identity-id');
        });
    });

    describe('getUserProfile', () => {

        it('should return user item if found', async () => {
            const fakeUser = { userId: 'user-123', scansCount: 5 };
            mockSend.mockResolvedValue({ Item: fakeUser });

            const result = await getUserProfile('user-123');

            expect(result).toEqual(fakeUser);
        });

        it('should return undefined if user not found', async () => {
            mockSend.mockResolvedValue({});

            const result = await getUserProfile('user-unknown');

            expect(result).toBeUndefined();
        });
    });

    describe('findUserByCognitoSub', () => {

        it('should return user if found by cognitoSub', async () => {
            const fakeUser = { userId: 'user-123', cognitoSub: 'sub-abc' };
            mockSend.mockResolvedValue({ Items: [fakeUser] });

            const result = await findUserByCognitoSub('sub-abc');

            expect(result).toEqual(fakeUser);
        });

        it('should return null if no user found', async () => {
            mockSend.mockResolvedValue({ Items: [] });

            const result = await findUserByCognitoSub('sub-unknown');

            expect(result).toBeNull();
        });
    });

    describe('linkUserToApple', () => {

        it('should call UpdateCommand with apple auth fields', async () => {
            mockSend.mockResolvedValue({});

            await linkUserToApple('user-123', { cognitoSub: 'sub-abc', email: 'test@example.com', givenName: 'Test name' });

            const calledWith = mockSend.mock.calls[0][0];

            expect(calledWith.input.Key.userId).toBe('user-123');
            expect(calledWith.input.ExpressionAttributeValues[':sub']).toBe('sub-abc');
            expect(calledWith.input.ExpressionAttributeValues[':email']).toBe('test@example.com');
            expect(calledWith.input.ExpressionAttributeValues[':name']).toBe('Test name');
            expect(calledWith.input.ExpressionAttributeValues[':provider']).toBe('apple');
        });
    });

    describe('updateUserDevice', () => {

        it('should call UpdateCommand with correct userId and deviceId', async () => {
            mockSend.mockResolvedValue({});

            await updateUserDevice('user-123', 'device-new');

            const calledWith = mockSend.mock.calls[0][0];
            expect(calledWith.input.Key.userId).toBe('user-123');
            expect(calledWith.input.ExpressionAttributeValues[':d']).toBe('device-new');
        });
    });

    describe('deleteUser', () => {

        it('should call DeleteCommand with correct userId key', async () => {
            mockSend.mockResolvedValue({});

            await deleteUser('user-123');

            const calledWith = mockSend.mock.calls[0][0];
            expect(calledWith.input.Key.userId).toBe('user-123');
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(deleteUser('user-123')).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
