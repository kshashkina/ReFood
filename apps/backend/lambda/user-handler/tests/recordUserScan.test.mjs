import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/scansDatabase.mjs', () => ({
    recordScan: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetrics: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { recordUserScan } from '../handlers/recordUserScan.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { recordScan } from '../services/scansDatabase.mjs';
import { invokeMetrics } from '../services/metricsService.mjs';

const makeEvent = (body = {}) => ({
    body: JSON.stringify(body),
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('recordUserScan', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
        recordScan.mockResolvedValue({});
        invokeMetrics.mockResolvedValue({});
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await recordUserScan(makeEvent({ barcode: '1234567890' }));

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not recognized' });
        });
    });

    describe('missing barcode', () => {

        it('should return 400 if barcode is missing', async () => {
            const result = await recordUserScan(makeEvent({}));

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'barcode is required' });
        });
    });

    describe('successful scan recording', () => {

        it('should return 201 with success=true', async () => {
            const result = await recordUserScan(makeEvent({ barcode: '1234567890', productName: 'Milk' }));

            expect(result.statusCode).toBe(201);
            expect(JSON.parse(result.body)).toMatchObject({ success: true });
        });

        it('should call invokeMetrics with "increment_scanned"', async () => {
            await recordUserScan(makeEvent({ barcode: '1234567890' }));

            expect(invokeMetrics).toHaveBeenCalledWith('increment_scanned', 'user-123');
        });
    });

    describe('error handling', () => {

        it('should return 500 if recordScan throws', async () => {
            recordScan.mockRejectedValue(new Error('DynamoDB unavailable'));

            const result = await recordUserScan(makeEvent({ barcode: '1234567890' }));

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to record scan' });
        });
    });
});
