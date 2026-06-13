import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/scansDatabase.mjs', () => ({
    getUserScans: vi.fn()
}));

vi.mock('../mappers/scanMapper.mjs', () => ({
    toScanListResponse: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetrics: vi.fn(),
    invokeMetricsSync: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { getDashboard } from '../handlers/getUserDashboard.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getUserScans } from '../services/scansDatabase.mjs';
import { toScanListResponse } from '../mappers/scanMapper.mjs';
import { invokeMetrics, invokeMetricsSync } from '../services/metricsService.mjs';

const makeEvent = () => ({
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('getDashboard', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await getDashboard(makeEvent());

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not recognized' });
        });
    });

    describe('successful dashboard load', () => {

        it('should return 200 with profile counts and recentScans', async () => {
            const fakeCounts = { scannedCount: 10, sortedCount: 5 };
            const fakeScans = [{ barcode: '1234567890', productName: 'Milk', image: null, timestamp: '2026-06-05T15:59:16.712Z' }];
            invokeMetricsSync.mockResolvedValue(fakeCounts);
            getUserScans.mockResolvedValue(fakeScans);
            toScanListResponse.mockReturnValue([{ barcode: '1234567890', name: 'Milk', image: null, date: '2026-06-05T15:59:16.712Z' }]);

            const result = await getDashboard(makeEvent());

            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);

            expect(body.profile.scannedCount).toBe(10);
            expect(body.profile.sortedCount).toBe(5);
            expect(body.recentScans).toHaveLength(1);
        });
    });
});
