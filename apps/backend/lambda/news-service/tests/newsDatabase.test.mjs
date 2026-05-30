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
    PutCommand: function (input) { this.input = input; },
    QueryCommand: function (input) { this.input = input; }
}));

import { checkNewsExists, saveNewsToDb, getLatestNewsFromDb } from '../services/newsDatabase.mjs';

const fakeArticle = {
    id: 'pmid-001',
    date: '2025-05-15',
    resource: 'Journal of Nutrition',
    ai_processed: {
        original_title_en: 'Title EN',
        takeaway_en: 'Some takeaway'
    }
};

describe('newsDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('checkNewsExists', () => {

        it('should return true if news item exists in DB', async () => {
            mockSendToDb.mockResolvedValue({ Item: { news_id: 'pmid-001' } });

            const result = await checkNewsExists('pmid-001');

            expect(result).toBe(true);
        });

        it('should return false if news item does not exist', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await checkNewsExists('pmid-unknown');

            expect(result).toBe(false);
        });

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(checkNewsExists('pmid-001')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('saveNewsToDb', () => {

        it('should save item with news_id', async () => {
            mockSendToDb.mockResolvedValue({});

            await saveNewsToDb(fakeArticle);

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.Item.news_id).toBe('pmid-001');
            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(saveNewsToDb(fakeArticle)).rejects.toThrow('DynamoDB unavailable');
        });

    });

    describe('getLatestNewsFromDb', () => {

        it('should return items array if found', async () => {
            const fakeItems = [{ news_id: 'pmid-001' }, { news_id: 'pmid-002' }];
            mockSendToDb.mockResolvedValue({ Items: fakeItems });

            const result = await getLatestNewsFromDb(10);

            expect(result).toEqual(fakeItems);
        });

        it('should return empty array if no items found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getLatestNewsFromDb(10);

            expect(result).toEqual([]);
        });

        it('should apply the specified limit', async () => {
            mockSendToDb.mockResolvedValue({ Items: [] });

            await getLatestNewsFromDb(5);

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.Limit).toBe(5);
        });

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getLatestNewsFromDb(10)).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
