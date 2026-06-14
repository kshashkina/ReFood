import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetricsSync: vi.fn()
}));

vi.mock('../helpers/response.mjs', () => ({
    response: vi.fn((status, body) => ({ statusCode: status, body: JSON.stringify(body) }))
}));

import { getAchievements } from '../handlers/getAchievements.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { invokeMetricsSync } from '../services/metricsService.mjs';

const makeEvent = () => ({
    requestContext: { authorizer: null, identity: null },
    headers: {}
});

describe('getAchievements', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ type: 'identity', id: 'id-123' });
        findUserIdByAnyMethod.mockResolvedValue('user-123');
    });

    describe('unauthorized', () => {

        it('should return 401 if userId is not found', async () => {
            findUserIdByAnyMethod.mockResolvedValue(null);

            const result = await getAchievements(makeEvent());

            expect(result.statusCode).toBe(401);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'User not recognized' });
        });
    });

    describe('metrics service failure', () => {

        it('should return 500 if invokeMetricsSync returns null', async () => {
            invokeMetricsSync.mockResolvedValue(null);

            const result = await getAchievements(makeEvent());

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to load achievements' });
        });
    });

    describe('successful achievements load', () => {

        it('should return 200 with achievements, totalUnlocked and total', async () => {
            invokeMetricsSync.mockResolvedValue({
                success: true,
                achievements: [{ id: 'first_scan', unlocked: true }],
                totalUnlocked: 1,
                total: 10
            });

            const result = await getAchievements(makeEvent());

            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.achievements).toHaveLength(1);
            expect(body.totalUnlocked).toBe(1);
            expect(body.total).toBe(10);
        });

        it('should call invokeMetricsSync with "get_achievements" action', async () => {
            invokeMetricsSync.mockResolvedValue({ success: true, achievements: [], totalUnlocked: 0, total: 0 });

            await getAchievements(makeEvent());

            expect(invokeMetricsSync).toHaveBeenCalledWith('get_achievements', 'user-123');
        });
    });

    describe('error handling', () => {

        it('should return 500 if invokeMetricsSync throws', async () => {
            invokeMetricsSync.mockRejectedValue(new Error('Lambda unavailable'));

            const result = await getAchievements(makeEvent());

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Failed to load achievements' });
        });
    });
});
