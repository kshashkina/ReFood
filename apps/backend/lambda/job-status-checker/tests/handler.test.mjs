import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../handlers/checkValidationImageStatus.mjs', () => ({
    checkValidationImageStatus: vi.fn()
}));

import { handler } from '../index.mjs';
import { checkValidationImageStatus } from '../handlers/checkValidationImageStatus.mjs';

describe('job-status-checker handler', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('GET /image-validation', () => {

        it('should call checkValidationImageStatus and return its response', async () => {
            checkValidationImageStatus.mockResolvedValue({ statusCode: 200, body: JSON.stringify({ status: 'PENDING' }) });

            const event = { httpMethod: 'GET', path: '/status/image-validation/img-001' };
            const result = await handler(event);

            expect(checkValidationImageStatus).toHaveBeenCalledWith(event);
            expect(result.statusCode).toBe(200);
        });
    });

    describe('unknown routes', () => {

        it('should return 404 for unknown GET path', async () => {
            const result = await handler({ httpMethod: 'GET', path: '/status/unknown' });

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Route not found' });
        });
    });

    describe('handling errors', () => {

        it('should return 500 if checkValidationImageStatus throws', async () => {
            checkValidationImageStatus.mockRejectedValue(new Error('DynamoDB unavailable'));

            const result = await handler({ httpMethod: 'GET', path: '/status/image-validation/img-001' });

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Internal server error' });
        });
    });
});
