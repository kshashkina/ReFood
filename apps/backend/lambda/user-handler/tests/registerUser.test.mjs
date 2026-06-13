import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserByDevice: vi.fn(),
    createUser: vi.fn(),
    updateIdentityId: vi.fn()
}));

vi.mock('../helpers/validation/userValidator.mjs', () => ({
    validateRegisterRequest: vi.fn()
}));

vi.mock('../mappers/userMapper.mjs', () => ({
    toUserDBModel: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { registerUser } from '../handlers/registerUser.mjs';
import { findUserByDevice, createUser, updateIdentityId } from '../services/usersDatabase.mjs';
import { validateRegisterRequest } from '../helpers/validation/userValidator.mjs';
import { toUserDBModel } from '../mappers/userMapper.mjs';

const makeEvent = (body = {}) => ({
    body: JSON.stringify(body),
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

const validBody = { deviceId: 'device-abc', identityId: 'identity-xyz' };

describe('registerUser', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        validateRegisterRequest.mockReturnValue({ valid: true, errors: [] });
        toUserDBModel.mockReturnValue({ userId: 'user-123', deviceId: 'device-abc', identityId: 'identity-xyz' });
    });

    describe('invalid request', () => {

        it('should return 400 for invalid JSON body', async () => {
            const result = await registerUser({ body: '{invalid json}', requestContext: {}, headers: {} });

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Invalid JSON body' });
        });

        it('should return 400 if validation fails', async () => {
            validateRegisterRequest.mockReturnValue({ valid: false, errors: ['Invalid or missing deviceId'] });

            const result = await registerUser(makeEvent({ identityId: 'identity-xyz' }));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Validation failed' });
        });
    });

    describe('existing user', () => {

        it('should return 200 and recognize user if device already exists', async () => {
            findUserByDevice.mockResolvedValue({ userId: 'user-123', identityId: 'identity-xyz' });

            const result = await registerUser(makeEvent(validBody));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'User recognized' });
        });

        it('should update identityId if it changed for existing user', async () => {
            findUserByDevice.mockResolvedValue({ userId: 'user-123', identityId: 'old-identity' });

            await registerUser(makeEvent(validBody));

            expect(updateIdentityId).toHaveBeenCalledWith('user-123', 'identity-xyz');
        });

        it('should NOT update identityId if it is the same', async () => {
            findUserByDevice.mockResolvedValue({ userId: 'user-123', identityId: 'identity-xyz' });

            await registerUser(makeEvent(validBody));

            expect(updateIdentityId).not.toHaveBeenCalled();
        });
    });

    describe('new user creation', () => {

        it('should create new user and return 201 if device not found', async () => {
            findUserByDevice.mockResolvedValue(null);
            createUser.mockResolvedValue({});

            const result = await registerUser(makeEvent(validBody));

            expect(createUser).toHaveBeenCalled();
            expect(result.statusCode).toBe(201);
            expect(JSON.parse(result.body)).toMatchObject({ message: 'New user created' });
        });
    });

    describe('error handling', () => {

        it('should return 500 if createUser throws error', async () => {
            findUserByDevice.mockResolvedValue(null);
            createUser.mockRejectedValue(new Error('DB unavailable'));

            const result = await registerUser(makeEvent(validBody));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to register user' });
        });
    });
});
