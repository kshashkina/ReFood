import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserByCognitoSub: vi.fn(),
    findUserByDevice: vi.fn(),
    linkUserToApple: vi.fn(),
    updateUserDevice: vi.fn(),
    deleteUser: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { registerLinkAccount } from '../handlers/registerLinkAccount.mjs';
import { findUserByCognitoSub, findUserByDevice, linkUserToApple, updateUserDevice, deleteUser } from '../services/usersDatabase.mjs';

const makeEvent = (body = {}, claims = { sub: 'cognito-sub-123' }) => ({
    body: JSON.stringify(body),
    requestContext: {
        authorizer: { claims }
    },
    headers: {}
});

describe('registerLinkAccount', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('unauthorized', () => {

        it('should return 401 if cognitoSub is missing', async () => {
            const result = await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }, null));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Missing or invalid authorization token' });
        });
    });

    describe('invalid request body', () => {

        it('should return 400 for invalid JSON body', async () => {
            const result = await registerLinkAccount({
                body: '{invalid}',
                requestContext: { authorizer: { claims: { sub: 'sub-123' } } }
            });

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid JSON body' });
        });

        it('should return 400 if deviceId is missing', async () => {
            const result = await registerLinkAccount(makeEvent({}));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Missing or invalid deviceId' });
        });
    });

    describe('existing Apple user', () => {

        it('should update device and return 200 "Welcome back" if Apple user already exists', async () => {
            const existingApple = { userId: 'apple-user-123' };
            findUserByCognitoSub.mockResolvedValue(existingApple);
            findUserByDevice.mockResolvedValue(null);
            updateUserDevice.mockResolvedValue({});

            const result = await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }));

            expect(updateUserDevice).toHaveBeenCalledWith('apple-user-123', 'device-abc');
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'Welcome back' });
        });

        it('should delete anonymous user if it differs from Apple user', async () => {
            const existingApple = { userId: 'apple-user-123' };
            const anonymousUser = { userId: 'anon-user-456' };
            findUserByCognitoSub.mockResolvedValue(existingApple);
            findUserByDevice.mockResolvedValue(anonymousUser);
            updateUserDevice.mockResolvedValue({});
            deleteUser.mockResolvedValue({});

            await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }));

            expect(deleteUser).toHaveBeenCalledWith('anon-user-456');
        });

        it('should NOT delete user if anonymous and Apple user are the same', async () => {
            const sameUser = { userId: 'apple-user-123' };
            findUserByCognitoSub.mockResolvedValue(sameUser);
            findUserByDevice.mockResolvedValue(sameUser);
            updateUserDevice.mockResolvedValue({});

            await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }));

            expect(deleteUser).not.toHaveBeenCalled();
        });
    });

    describe('link anonymous user to Apple', () => {

        it('should link anonymous user and return 200 "Account linked"', async () => {
            findUserByCognitoSub.mockResolvedValue(null);
            const anonymousUser = { userId: 'anon-user-456' };
            findUserByDevice.mockResolvedValue(anonymousUser);
            linkUserToApple.mockResolvedValue({});

            const result = await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }, { sub: 'sub-123', email: 'test@test.com', given_name: 'Test' }));

            expect(linkUserToApple).toHaveBeenCalledWith('anon-user-456', {
                cognitoSub: 'sub-123',
                email: 'test@test.com',
                givenName: 'Test'
            });
            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'Account linked' });
        });
    });

    describe('error handling', () => {

        it('should return 500 if DB throws', async () => {
            findUserByCognitoSub.mockRejectedValue(new Error('DB unavailable'));

            const result = await registerLinkAccount(makeEvent({ deviceId: 'device-abc' }));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to link account' });
        });
    });
});
