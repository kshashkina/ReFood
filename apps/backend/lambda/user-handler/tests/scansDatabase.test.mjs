import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSend } = vi.hoisted(() => ({
    mockSend: vi.fn()
}));

vi.mock('@aws-sdk/client-dynamodb', () => ({
    DynamoDBClient: function () { }
}));

vi.mock('@aws-sdk/lib-dynamodb', () => ({
    DynamoDBDocumentClient: {
        from: vi.fn().mockReturnValue({ send: mockSend })
    },
    QueryCommand: function (input) { this.input = input; },
    DeleteCommand: function (input) { this.input = input; },
    PutCommand: function (input) { this.input = input; }
}));

import { getUserScans, getUserScansPaginated, deleteAllUserScans, recordScan } from '../services/scansDatabase.mjs';

const fakeScanData = {
    barcode: '1234567890',
    productName: 'Test Product',
    productBrand: 'TestBrand',
    image: 'https://example.com/img.jpg',
    productVersion: 17000000
};

describe('scansDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getUserScans', () => {

        it('should return items array on success', async () => {
            const fakeScans = [{ userId: 'user-123', barcode: '1234567890', timestamp: '2026-06-05T15:59:16.712Z' }];
            mockSend.mockResolvedValue({ Items: fakeScans });

            const result = await getUserScans('user-123');

            expect(result).toEqual(fakeScans);
        });

        it('should return empty array if no scans', async () => {
            mockSend.mockResolvedValue({ Items: [] });

            const result = await getUserScans('user-123');

            expect(result).toEqual([]);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getUserScans('user-123')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('getUserScansPaginated', () => {

        it('should return items and null lastKey if no more pages', async () => {
            mockSend.mockResolvedValue({ Items: [{ barcode: '1234567890' }], LastEvaluatedKey: undefined });

            const result = await getUserScansPaginated('user-123');

            expect(result.items).toEqual([{ barcode: '1234567890' }]);
            expect(result.lastKey).toBeNull();
        });

        it('should return lastKey if more pages exist', async () => {
            const lastKey = { userId: 'user-123', timestamp: '2026-06-05T15:59:16.712Z' };
            mockSend.mockResolvedValue({ Items: [], LastEvaluatedKey: lastKey });

            const result = await getUserScansPaginated('user-123');

            expect(result.lastKey).toEqual(lastKey);
        });

        it('should pass ExclusiveStartKey if lastKey is provided', async () => {
            mockSend.mockResolvedValue({ Items: [] });
            const lastKey = { userId: 'user-123', timestamp: '2026-06-05T15:59:16.712Z' };

            await getUserScansPaginated('user-123', 20, lastKey);

            const calledWith = mockSend.mock.calls[0][0];
            expect(calledWith.input.ExclusiveStartKey).toEqual(lastKey);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getUserScansPaginated('user-123')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('deleteAllUserScans', () => {

        it('should do nothing if user has no scans', async () => {
            mockSend.mockResolvedValue({ Items: [], LastEvaluatedKey: undefined });

            await deleteAllUserScans('user-123');

            expect(mockSend).toHaveBeenCalledTimes(1);
        });

        it('should delete all scans for a user', async () => {
            mockSend.mockResolvedValueOnce({
                Items: [
                    { userId: 'user-123', timestamp: '2026-06-05T15:59:16.712Z' },
                    { userId: 'user-123', timestamp: '2026-06-05T15:59:16.712Z' }
                ],
                LastEvaluatedKey: undefined
            }).mockResolvedValue({});

            await deleteAllUserScans('user-123');

            expect(mockSend).toHaveBeenCalledTimes(3);
        });
    });

    describe('recordScan', () => {
        it('should record scan with correct userId, barcode, product name, product brand and image', async () => {
            mockSend.mockResolvedValue({});

            await recordScan('user-123', fakeScanData);

            const calledWith = mockSend.mock.calls[0][0];
            expect(calledWith.input.Item.userId).toBe('user-123');
            expect(calledWith.input.Item.barcode).toBe('1234567890');
            expect(calledWith.input.Item.productName).toBe('Test Product');
            expect(calledWith.input.Item.productBrand).toBe('TestBrand');
            expect(calledWith.input.Item.image).toBe('https://example.com/img.jpg');
        })

        it('should throw if DynamoDB is unavailable', async () => {
            mockSend.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(recordScan('user-123', fakeScanData)).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
