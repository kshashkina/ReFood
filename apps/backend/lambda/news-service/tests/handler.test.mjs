import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/fetchPubMedApi.mjs', () => ({
    fetchNewsFromPubMed: vi.fn()
}));

vi.mock('../services/newsDatabase.mjs', () => ({
    checkNewsExists: vi.fn(),
    saveNewsToDb: vi.fn(),
    getLatestNewsFromDb: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    processNewsWithAI: vi.fn()
}));

vi.mock('../services/dailyTipsDatabase.mjs', () => ({
    getDailyTip: vi.fn()
}));

import { handler } from '../index.mjs';
import { getLatestNewsFromDb } from '../services/newsDatabase.mjs';
import { getDailyTip } from '../services/dailyTipsDatabase.mjs';

describe('news-service handler', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('HTTP GET /daily-dashboard', () => {

        it('should call getSummaryHandler and return 200', async () => {
            getDailyTip.mockResolvedValue({ Item: null });
            getLatestNewsFromDb.mockResolvedValue([]);

            const result = await handler({ httpMethod: 'GET', path: '/news/daily-dashboard' });

            expect(result.statusCode).toBe(200);
        });
    });

    describe('unknown routes', () => {

        it('should return 404 for unknown GET path', async () => {
            const result = await handler({ httpMethod: 'GET', path: '/news/unknown-route' });

            expect(result.statusCode).toBe(404);
        });
    });

    describe('handling errors', () => {

        it('should return 500 if getSummaryHandler throws', async () => {
            getDailyTip.mockRejectedValue(new Error('DynamoDB unavailable'));
            getLatestNewsFromDb.mockResolvedValue([]);

            const result = await handler({ httpMethod: 'GET', path: '/news/daily-dashboard' });

            expect(result.statusCode).toBe(500);
        });
    });
});
