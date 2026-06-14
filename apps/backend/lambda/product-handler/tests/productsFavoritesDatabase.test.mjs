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
    DeleteCommand: function (input) { this.input = input; }
}));

import { getFavorite, addFavorite, removeFavorite } from '../services/databases/productsFavoritesDatabase.mjs';

const fakeProduct = {
    barcode: '1234567890',
    product_name: 'Test Product',
    brands: 'TestBrand',
    updated_at: 17000000,
    image_url: 'https://example.com/img.jpg'
};

describe('productsFavoritesDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getFavorite', () => {

        it('should return the item if found', async () => {
            const fakeItem = { userId: 'user-123', barcode: '1234567890', productVersion: 17000000 };
            mockSendToDb.mockResolvedValue({ Item: fakeItem });

            const result = await getFavorite('user-123', '1234567890');

            expect(result).toEqual(fakeItem);
        });

        it('should return null if item not found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getFavorite('user-123', '0000000000');

            expect(result).toBeNull();
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getFavorite('user-123', '1234567890')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('addFavorite', () => {

        it('should store the correct fields in DynamoDB', async () => {
            mockSendToDb.mockResolvedValue({});
            await addFavorite('user-123', fakeProduct);

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

            await expect(addFavorite('user-123', fakeProduct)).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('removeFavorite', () => {

        it('should call DeleteCommand with correct userId and barcode', async () => {
            mockSendToDb.mockResolvedValue({});
            await removeFavorite('user-123', '1234567890');

            const calledWith = mockSendToDb.mock.calls[0][0];

            expect(calledWith.input.Key.userId).toBe('user-123');
            expect(calledWith.input.Key.barcode).toBe('1234567890');
        });


        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(removeFavorite('user-123', '1234567890')).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
