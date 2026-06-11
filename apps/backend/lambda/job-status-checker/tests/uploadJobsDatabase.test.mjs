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
    GetCommand: function (input) { this.input = input; }
}));

import { getJobStatus } from '../services/uploadJobsDatabse.mjs';

describe('getJobStatus', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful queries to jobs database', () => {

        it('should return job item if found', async () => {
            const fakeJob = { status: 'PENDING' };
            mockSendToDb.mockResolvedValue({ Item: fakeJob });

            const result = await getJobStatus('img-001');

            expect(result).toEqual(fakeJob);
        });

        it('should return job with APPROVED status', async () => {
            mockSendToDb.mockResolvedValue({ Item: { status: 'APPROVED' } });

            const result = await getJobStatus('img-001');

            expect(result.status).toBe('APPROVED');
        });

        it('should return job with REJECTED status and error fields', async () => {
            const fakeJob = { status: 'REJECTED', error_en: 'Not food', error_ua: 'Не їжа' };
            mockSendToDb.mockResolvedValue({ Item: fakeJob });

            const result = await getJobStatus('img-001');

            expect(result).toMatchObject({ status: 'REJECTED', error_en: 'Not food', error_ua: 'Не їжа' });
        });

        it('should return null if job not found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getJobStatus('img-unknown');

            expect(result).toBeNull();
        });

        it('should call DynamoDB send once', async () => {
            mockSendToDb.mockResolvedValue({ Item: { status: 'PENDING' } });

            await getJobStatus('img-001');

            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });

        it('should query with the correct imageId key', async () => {
            mockSendToDb.mockResolvedValue({ Item: { status: 'PENDING' } });

            await getJobStatus('img-001');

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.Key.imageId).toBe('img-001');
        });
    });

    describe('handling errors', () => {

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getJobStatus('img-001')).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
