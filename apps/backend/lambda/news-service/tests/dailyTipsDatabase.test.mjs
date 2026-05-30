import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSendToDb } = vi.hoisted(() => ({
    mockSendToDb: vi.fn()
}));

vi.mock('@aws-sdk/client-dynamodb', () => ({
    DynamoDBClient: function () { }
}));

vi.mock('@aws-sdk/lib-dynamodb', () => ({
    DynamoDBDocumentClient: {
        from: vi.fn().mockReturnValue({ send: mockSendToDb })
    },
    GetCommand: function (input) { this.input = input; },
    PutCommand: function (input) { this.input = input; }
}));

import { getDailyTip } from '../services/dailyTipsDatabase.mjs';

describe('dailyTipsDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getDailyTip', () => {

        it('should return tip item if found', async () => {
            const fakeTip = { tip_date: '01.06', tip_en: 'Eat vegetables', tip_ua: 'Їжте овочі' };
            mockSendToDb.mockResolvedValue({ Item: fakeTip });

            const result = await getDailyTip('01.06');

            expect(result.Item).toEqual(fakeTip);
            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should return undefined if tip not found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getDailyTip('31.12');

            expect(result.Item).toBeUndefined();
        });

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getDailyTip('01.06')).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
