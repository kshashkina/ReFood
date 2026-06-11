import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/uploadJobsDatabse.mjs', () => ({
    getJobStatus: vi.fn()
}));

import { checkValidationImageStatus } from '../handlers/checkValidationImageStatus.mjs';
import { getJobStatus } from '../services/uploadJobsDatabse.mjs';

const makeEvent = (imageId, via = 'pathParameters') => {
    if (via === 'pathParameters') {
        return { pathParameters: { imageId }, queryStringParameters: null };
    }
    return { pathParameters: null, queryStringParameters: { imageId } };
};

describe('checkValidationImageStatus', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('missing imageId', () => {

        it('should return 400 if imageId is missing in both path and query', async () => {
            const event = { pathParameters: null, queryStringParameters: null };

            const result = await checkValidationImageStatus(event);

            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Missing imageId' });
        });

        it('should return 400 if event has no parameters at all', async () => {
            const result = await checkValidationImageStatus({});

            expect(result.statusCode).toBe(400);
        });
    });

    describe('job not found', () => {

        it('should return 404 if job does not exist in DB', async () => {
            getJobStatus.mockResolvedValue(null);

            const result = await checkValidationImageStatus(makeEvent('img-unknown'));

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Job not found' });
        });
    });

    describe('successful status check', () => {

        it('should return 200 with status PENDING', async () => {
            getJobStatus.mockResolvedValue({ status: 'PENDING' });

            const result = await checkValidationImageStatus(makeEvent('img-001'));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ status: 'PENDING' });
        });

        it('should return 200 with status APPROVED', async () => {
            getJobStatus.mockResolvedValue({ status: 'APPROVED' });

            const result = await checkValidationImageStatus(makeEvent('img-001'));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ status: 'APPROVED' });
        });

        it('should return status REJECTED and error fields ', async () => {
            getJobStatus.mockResolvedValue({ status: 'REJECTED', error_en: 'Not food', error_ua: 'Не їжа' });

            const result = await checkValidationImageStatus(makeEvent('img-001'));

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ status: 'REJECTED', error_en: 'Not food', error_ua: 'Не їжа' });
        });

        it('should NOT include error fields in body when status is not REJECTED', async () => {
            getJobStatus.mockResolvedValue({ status: 'APPROVED', error_en: undefined, error_ua: undefined });

            const result = await checkValidationImageStatus(makeEvent('img-001'));

            const body = JSON.parse(result.body);
            expect(body).not.toHaveProperty('error_en');
            expect(body).not.toHaveProperty('error_ua');
        });

        it('should accept imageId from queryStringParameters', async () => {
            getJobStatus.mockResolvedValue({ status: 'PENDING' });

            const result = await checkValidationImageStatus(makeEvent('img-001', 'queryStringParameters'));

            expect(result.statusCode).toBe(200);
            expect(getJobStatus).toHaveBeenCalledWith('img-001');
        });
    });

    describe('handling errors', () => {

        it('should throw error if DB call fails', async () => {
            getJobStatus.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(checkValidationImageStatus(makeEvent('img-001'))).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
