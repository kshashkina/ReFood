import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserByDevice: vi.fn(),
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { getUserId } from '../handlers/getUserId.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserByDevice, findUserIdByAnyMethod } from '../services/usersDatabase.mjs';

const makeEvent = (query = {}) => ({
    queryStringParameters: query,
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('getUserId', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
    });

    describe('missing deviceId', () => {

        it('should return 400 if deviceId is not provided', async () => {
            const result = await getUserId(makeEvent());

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Missing required query parameter: deviceId' });
        });
    });

    describe('unauthorized', () => {

        it('should return 401 if identity is null', async () => {
            getRequestIdentity.mockReturnValue(null);

            const result = await getUserId(makeEvent({ deviceId: 'device-abc' }));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Unauthorized' });
        });
    });

    describe('user not found', () => {

        it('should return 404 if userByDevice is null', async () => {
            findUserByDevice.mockResolvedValue(null);
            findUserIdByAnyMethod.mockResolvedValue('user-123');

            const result = await getUserId(makeEvent({ deviceId: 'device-abc' }));

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not found' });
        });
    });

    describe('successful userId return', () => {

        it('should return 200 with userId', async () => {
            findUserByDevice.mockResolvedValue({ userId: 'user-123' });
            findUserIdByAnyMethod.mockResolvedValue('user-123');

            const result = await getUserId(makeEvent({ deviceId: 'device-abc' }));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ userId: 'user-123' });
        });
    });

    describe('error handling', () => {

        it('should return 500 if DB throws', async () => {
            findUserByDevice.mockRejectedValue(new Error('DB unavailable'));

            const result = await getUserId(makeEvent({ deviceId: 'device-abc' }));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to retrieve user ID' });
        });
    });
});
