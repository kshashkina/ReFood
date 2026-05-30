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
    PutCommand: function (input) { this.input = input; },
    UpdateCommand: function (input) { this.input = input; },
    GetCommand: function (input) { this.input = input; }
}));

import { createPendingJob, updateJobStatus, getJobStatus } from '../services/uploadJobsDatabase.mjs';

describe('uploadJobsDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('createPendingJob', () => {

        it('should create item with status PENDING', async () => {
            mockSendToDb.mockResolvedValue({});

            await createPendingJob('img-001', 'temp/img-001.jpg');

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.Item.status).toBe('PENDING');
            expect(calledWith.input.Item.imageId).toBe('img-001');
            expect(calledWith.input.Item.s3Key).toBe('temp/img-001.jpg');
            expect(calledWith.input.Item.ttl).toBeTypeOf('number');
            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(createPendingJob('img-001', 'temp/img-001.jpg')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('updateJobStatus', () => {

        it('should update status in expression attributes', async () => {
            mockSendToDb.mockResolvedValue({});

            await updateJobStatus('img-001', 'REJECTED', 'Not a food item', 'Не є харчовим продуктом');

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.ExpressionAttributeValues[':status']).toBe('REJECTED');
            expect(calledWith.input.ExpressionAttributeValues[':error_en']).toBe('Not a food item');
            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(updateJobStatus('img-001', 'APPROVED', null, null)).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('getJobStatus', () => {

        it('should return item if found', async () => {
            const fakeJob = { imageId: 'img-001', status: 'APPROVED' };
            mockSendToDb.mockResolvedValue({ Item: fakeJob });

            const result = await getJobStatus('img-001');

            expect(result).toEqual(fakeJob);
        });

        it('should return null if item not found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getJobStatus('img-unknown');

            expect(result).toBeNull();
        });

        it('should throw if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getJobStatus('img-001')).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
