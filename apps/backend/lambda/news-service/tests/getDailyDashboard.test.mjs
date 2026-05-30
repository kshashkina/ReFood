import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/dailyTipsDatabase.mjs', () => ({
    getDailyTip: vi.fn()
}));

vi.mock('../services/newsDatabase.mjs', () => ({
    getLatestNewsFromDb: vi.fn()
}));

import { getSummary } from '../handlers/getDailyDashboard.mjs';
import { getDailyTip } from '../services/dailyTipsDatabase.mjs';
import { getLatestNewsFromDb } from '../services/newsDatabase.mjs';

const fakeTip = {
    tip_date: '01.06',
    tip_en: 'Eat more vegetables',
    tip_ua: 'Їжте більше овочів'
};

const fakeNews = [
    { news_id: 'pmid-001', simplified_title_en: 'Article 1' },
    { news_id: 'pmid-002', simplified_title_en: 'Article 2' }
];

const makeEvent = (timestamp = null) => ({
    requestContext: timestamp ? { timeEpoch: timestamp } : {}
});

describe('getSummary', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful response', () => {

        it('should return 200 with tip and news', async () => {
            getDailyTip.mockResolvedValue({ Item: fakeTip });
            getLatestNewsFromDb.mockResolvedValue(fakeNews);

            const result = await getSummary(makeEvent());

            expect(result.statusCode).toBe(200);

            const body = JSON.parse(result.body);
            expect(body.tip).toEqual(fakeTip);
            expect(body.news).toEqual(fakeNews);
        });

        it('should return tip=null if no tip found for today', async () => {
            getDailyTip.mockResolvedValue({ Item: null });
            getLatestNewsFromDb.mockResolvedValue([]);

            const result = await getSummary(makeEvent());

            const body = JSON.parse(result.body);
            expect(body.tip).toBeNull();
        });

        it('should return news=[] if no news found', async () => {
            getDailyTip.mockResolvedValue({ Item: fakeTip });
            getLatestNewsFromDb.mockResolvedValue(null);

            const result = await getSummary(makeEvent());

            const body = JSON.parse(result.body);
            expect(body.news).toEqual([]);
        });

        it('should use timeEpoch from requestContext if provided', async () => {
            const timestamp = new Date('2025-12-31T12:00:00Z').getTime();
            getDailyTip.mockResolvedValue({ Item: null });
            getLatestNewsFromDb.mockResolvedValue([]);

            const result = await getSummary(makeEvent(timestamp));

            const body = JSON.parse(result.body);
            expect(body.date_utc).toBe('2025-12-31');
        });

        it('should call getLatestNewsFromDb with limit 10', async () => {
            getDailyTip.mockResolvedValue({ Item: null });
            getLatestNewsFromDb.mockResolvedValue([]);

            await getSummary(makeEvent());

            expect(getLatestNewsFromDb).toHaveBeenCalledWith(10);
        });
    });

    describe('handling errors', () => {

        it('should throw if getDailyTip fails', async () => {
            getDailyTip.mockRejectedValue(new Error('DynamoDB unavailable'));
            getLatestNewsFromDb.mockResolvedValue([]);

            await expect(getSummary(makeEvent())).rejects.toThrow('DynamoDB unavailable');
        });

        it('should throw if getLatestNewsFromDb fails', async () => {
            getDailyTip.mockResolvedValue({ Item: null });
            getLatestNewsFromDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getSummary(makeEvent())).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
