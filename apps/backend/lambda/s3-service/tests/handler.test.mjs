import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../handlers/getPresignedUrl.mjs', () => ({
    getPresignedUrl: vi.fn()
}));

vi.mock('../handlers/validateImage.mjs', () => ({
    validateImage: vi.fn()
}));

vi.mock('../handlers/finalizeUpload.mjs', () => ({
    finalizeUpload: vi.fn()
}));

import { handler } from '../index.mjs';
import { getPresignedUrl } from '../handlers/getPresignedUrl.mjs';
import { finalizeUpload } from '../handlers/finalizeUpload.mjs';

describe('s3-service handler', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('action finalize_upload', () => {

        it('should call finalizeUpload if event.action is finalize_upload', async () => {
            finalizeUpload.mockResolvedValue({ success: true, imageId: 'img-001', publicKey: 'public/img-001.jpg' });

            const event = { action: 'finalize_upload', imageId: 'img-001', s3Key: 'temp/img-001.jpg', barcode: '1234567890' };
            const result = await handler(event);

            expect(finalizeUpload).toHaveBeenCalledWith(event);
            expect(result.success).toBe(true);
        });

    });

    describe('GET /upload-url', () => {

        it('should call getPresignedUrl and return 200', async () => {
            getPresignedUrl.mockResolvedValue({ statusCode: 200, body: JSON.stringify({ uploadUrl: 'https://s3.example.com/presigned' }) });

            const event = { httpMethod: 'GET', path: '/s3/upload-url' };
            const result = await handler(event);

            expect(getPresignedUrl).toHaveBeenCalledWith(event);
            expect(result.statusCode).toBe(200);
        });
    });

    describe('unknown routes', () => {

        it('should return 404 for unknown path', async () => {
            const result = await handler({ httpMethod: 'GET', path: '/s3/unknown' });

            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Route not found in S3Service' });
        });
    });

    describe('handling errors', () => {

        it('should return 500 if getPresignedUrl throws', async () => {
            getPresignedUrl.mockRejectedValue(new Error('Internal server error'));

            const result = await handler({ httpMethod: 'GET', path: '/s3/upload-url' });

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Internal server error' });
        });
    });
});
