import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/scansDatabase.mjs', () => ({
    getUserScansPaginated: vi.fn()
}));

vi.mock('../mappers/scanMapper.mjs', () => ({
    toScanListResponse: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { getUserScanHistory } from '../handlers/getUserScanHistory.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getUserScansPaginated } from '../services/scansDatabase.mjs';
import { toScanListResponse } from '../mappers/scanMapper.mjs';

const makeEvent = (query = {}) => ({
    queryStringParameters: query,
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('getUserScanHistory', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
        getUserScansPaginated.mockResolvedValue({ items: [], lastKey: null });
        toScanListResponse.mockReturnValue([]);
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await getUserScanHistory(makeEvent());

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not recognized' });
        });
    });

    describe('successful scan history', () => {

        it('should return 200 with scans array', async () => {
            const fakeScans = [{ barcode: '1234567890', productName: 'Milk', image: null, timestamp: '2026-06-05T15:59:16.712Z' }];
            getUserScansPaginated.mockResolvedValue({ items: fakeScans, lastKey: null });
            toScanListResponse.mockReturnValue([{ barcode: '1234567890', name: 'Milk', image: null, date: '2026-06-05T15:59:16.712Z' }]);

            const result = await getUserScanHistory(makeEvent());

            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.scans).toHaveLength(1);
        });

        it('should include nextToken in response if there are more pages', async () => {
            const lastKey = { userId: 'user-123', timestamp: '2026-06-05T15:59:16.712Z' };
            getUserScansPaginated.mockResolvedValue({ items: [], lastKey });
            toScanListResponse.mockReturnValue([]);

            const result = await getUserScanHistory(makeEvent());

            const body = JSON.parse(result.body);
            expect(body.nextToken).toBeDefined();
        });

        it('should NOT include nextToken if no more pages', async () => {
            getUserScansPaginated.mockResolvedValue({ items: [], lastKey: null });

            const result = await getUserScanHistory(makeEvent());

            const body = JSON.parse(result.body);
            expect(body.nextToken).toBeUndefined();
        });
    });
});
