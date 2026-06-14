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

import { recordScan } from '../services/databases/scansDatabase.mjs';

const fakeProduct = {
    barcode: '1234567890',
    product_name: 'Test Product',
    brand: 'TestBrand',
    updated_at: 17000000,
    image_url: 'https://example.com/img.jpg'
};

describe('scansDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('recordScan', () => {

        it('should record a scan with the correct userId, barcode and product info', async () => {
            mockSendToDb.mockResolvedValue({});
            await recordScan('user-123', fakeProduct);

            const calledWith = mockSendToDb.mock.calls[0][0];

            expect(calledWith.input.Item.userId).toBe('user-123');
            expect(calledWith.input.Item.barcode).toBe('1234567890');
            expect(calledWith.input.Item.productName).toBe('Test Product');
            expect(calledWith.input.Item.productBrand).toBe('TestBrand');
            expect(calledWith.input.Item.image).toBe('https://example.com/img.jpg');
            expect(calledWith.input.Item.productVersion).toBe(17000000);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(recordScan('user-1', fakeProduct)).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
