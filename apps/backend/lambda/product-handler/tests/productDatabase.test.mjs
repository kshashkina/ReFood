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

import { getLatestProductFromDB, saveProductToDB } from '../services/databases/productDatabase.mjs';

describe('productDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getLatestProductFromDB', () => {

        it('should return the first item if found', async () => {
            const fakeProduct = { barcode: '1234567890', product_name: 'Test', updated_at: 1000 };
            mockSendToDb.mockResolvedValue({ Items: [fakeProduct] });

            const result = await getLatestProductFromDB('1234567890');

            expect(result).toEqual(fakeProduct);
        });

        it('should return null if no items found', async () => {
            mockSendToDb.mockResolvedValue({ Items: [] });

            const result = await getLatestProductFromDB('1234567890');

            expect(result).toBeNull();
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getLatestProductFromDB('1234567890')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('saveProductToDB', () => {

        it('should call send with the correct product item', async () => {
            mockSendToDb.mockResolvedValue({});
            const product = { barcode: '1234567890', product_name: 'Test', updated_at: 17000000 };
            await saveProductToDB(product);

            const calledWith = mockSendToDb.mock.calls[0][0];

            expect(calledWith.input.Item).toEqual(product);
            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(saveProductToDB({ barcode: '1234567890', product_name: 'Test', updated_at: 17000000 })).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
