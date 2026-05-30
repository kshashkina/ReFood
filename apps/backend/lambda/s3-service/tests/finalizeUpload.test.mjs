import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../helpers/checkApprovedStatus.mjs', () => ({
    requireApprovedJob: vi.fn()
}));

vi.mock('../helpers/checkS3File.mjs', () => ({
    fileExistsInS3: vi.fn()
}));

vi.mock('@aws-sdk/client-s3', () => ({
    S3Client: function () { this.send = vi.fn(); },
    CopyObjectCommand: function (input) { this.input = input; },
    DeleteObjectCommand: function (input) { this.input = input; }
}));

import { finalizeUpload } from '../handlers/finalizeUpload.mjs';
import { requireApprovedJob } from '../helpers/checkApprovedStatus.mjs';
import { fileExistsInS3 } from '../helpers/checkS3File.mjs';

const baseEvent = {
    s3Key: 'temp/img-001.jpg',
    imageId: 'img-001',
    barcode: '1234567890'
};

describe('finalizeUpload', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('missing required fields', () => {

        it('should throw if s3Key is missing', async () => {
            const fakeEvent = { s3Key: "", imageId: "img-001", barcode: "1234567890" };
            await expect(finalizeUpload(fakeEvent)).rejects.toThrow('Missing required fields');
        });

        it('should throw if imageId is missing', async () => {
            const fakeEvent = { s3Key: "temp/img-001.jpg", imageId: "", barcode: "1234567890" };
            await expect(finalizeUpload(fakeEvent)).rejects.toThrow('Missing required fields');
        });

        it('should throw if barcode is missing', async () => {
            const fakeEvent = { s3Key: "temp/img-001.jpg", imageId: "img-001", barcode: "" };
            await expect(finalizeUpload(fakeEvent)).rejects.toThrow('Missing required fields');
        });

        it('should throw if s3Key does not start with temp/', async () => {
            const fakeEvent = { s3Key: "public/img-001.jpg", imageId: "img-001", barcode: "1234567890" };
            await expect(finalizeUpload(fakeEvent)).rejects.toThrow('Invalid s3Key');
        });
    });

    describe('file already finalized', () => {

        it('should return success=true with already finalized if file is already in public', async () => {
            requireApprovedJob.mockResolvedValue({ ok: true, job: { status: 'APPROVED' } });
            fileExistsInS3
                .mockResolvedValueOnce(false)
                .mockResolvedValueOnce(true);

            const result = await finalizeUpload(baseEvent);

            expect(result.success).toBe(true);
            expect(result.alreadyFinalized).toBe(true);
        });

        it('should return FILE_NOT_FOUND if neither temp nor public exist', async () => {
            requireApprovedJob.mockResolvedValue({ ok: true, job: { status: 'APPROVED' } });
            fileExistsInS3.mockResolvedValue(false);

            const result = await finalizeUpload(baseEvent);

            expect(result.success).toBe(false);
            expect(result.code).toBe('FILE_NOT_FOUND');
        });

    });

    describe('successful finalization', () => {

        it('should return success=true with publicKey and publicUrl', async () => {
            requireApprovedJob.mockResolvedValue({ ok: true, job: { status: 'APPROVED' } });
            fileExistsInS3.mockResolvedValue(true);

            const result = await finalizeUpload(baseEvent);

            expect(result.success).toBe(true);
            expect(result.imageId).toBe('img-001');
            expect(result.publicKey).toContain('public/products/1234567890/img-001');
        });
    });
});
