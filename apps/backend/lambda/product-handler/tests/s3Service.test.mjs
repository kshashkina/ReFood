import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSend } = vi.hoisted(() => ({
    mockSend: vi.fn()
}));

vi.mock('@aws-sdk/client-lambda', () => ({
    LambdaClient: function () { this.send = mockSend; },
    InvokeCommand: function (input) { this.input = input; }
}));

import { finalizeImage } from '../services/s3Service.mjs';

const makeSuccessPayload = (data) => Buffer.from(JSON.stringify(data));

describe('s3Service', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should return the response payload on success', async () => {
        const fakeResponse = { success: true, imageId: 'img-001', publicKey: 'public/products/1234567890/img-001.jpg' };
        mockSend.mockResolvedValue({ Payload: makeSuccessPayload(fakeResponse), FunctionError: undefined });

        const result = await finalizeImage({ s3Key: 'temp/img-001.jpg', imageId: 'img-001', barcode: '1234567890' });

        expect(result).toEqual(fakeResponse);
    });

    it('should invoke with action "finalize_upload"', async () => {
        mockSend.mockResolvedValue({ Payload: makeSuccessPayload({}), FunctionError: undefined });
        await finalizeImage({ s3Key: 'temp/img-001.jpg', imageId: 'img-001', barcode: '1234567890' });

        const command = mockSend.mock.calls[0][0];
        const payload = JSON.parse(command.input.Payload);

        expect(payload.action).toBe('finalize_upload');
    });

    it('should pass s3Key, imageId and barcode in the payload', async () => {
        mockSend.mockResolvedValue({ Payload: makeSuccessPayload({}), FunctionError: undefined });
        await finalizeImage({ s3Key: 'temp/img-001.jpg', imageId: 'img-001', barcode: '1234567890' });

        const command = mockSend.mock.calls[0][0];
        const payload = JSON.parse(command.input.Payload);

        expect(payload.s3Key).toBe('temp/img-001.jpg');
        expect(payload.imageId).toBe('img-001');
        expect(payload.barcode).toBe('1234567890');
    });

    it('should throw an error if FunctionError is returned', async () => {
        mockSend.mockResolvedValue({
            Payload: makeSuccessPayload({ message: "Something went wrong" }),
            FunctionError: 'Error'
        });

        await expect(finalizeImage({ s3Key: 'temp/img-001.jpg', imageId: 'img-001', barcode: '1234567890' })).rejects.toThrow('S3Service invocation failed: Error');
    });
});
