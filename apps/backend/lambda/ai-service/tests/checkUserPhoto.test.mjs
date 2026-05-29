import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockGenerateContent } = vi.hoisted(() => ({
    mockGenerateContent: vi.fn()
}));

vi.mock('../services/vertexai.mjs', () => ({
    getModel: vi.fn(() => ({
        generateContent: mockGenerateContent
    }))
}));

const mockFetch = vi.fn();
global.fetch = mockFetch;

import { checkUserPhoto } from '../actions/checkUserPhoto.mjs';

const mockAIResponse = (responseObj) => {
    mockGenerateContent.mockResolvedValue({
        response: {
            candidates: [{
                content: {
                    parts: [{ text: JSON.stringify(responseObj) }]
                }
            }]
        }
    });
};

const fakeArrayBuffer = new ArrayBuffer(8);
const fakeImageUrl = 'https://s3.amazonaws.com/fake-refood-bucket/fake-product-image.jpg';

describe('checkUserPhoto', () => {

    beforeEach(() => {
        vi.clearAllMocks();

        mockFetch.mockResolvedValue({
            ok: true,
            arrayBuffer: async () => fakeArrayBuffer,
            headers: { get: () => 'image/jpeg' }
        });
    });

    describe('processing input image', () => {

        it('should fetch image from URL, pass it to Vertex AI and return canBeSaved=true', async () => {
            mockAIResponse({ isValid: true, detectedObject: 'Milk package on a table' });

            const result = await checkUserPhoto(fakeImageUrl);

            expect(mockFetch).toHaveBeenCalledWith(fakeImageUrl);
            expect(result.isValid).toBe(true);
            expect(result.canBeSaved).toBe(true);
        });

        it('should return canBeSaved=false if AI marks image as invalid', async () => {
            mockAIResponse({ isValid: false, error_en: 'Not food', error_ua: 'Не їжа' });

            const result = await checkUserPhoto(fakeImageUrl);

            expect(result.isValid).toBe(false);
            expect(result.canBeSaved).toBe(false);
        });

        it('should throw error if S3 fetch fails', async () => {
            mockFetch.mockResolvedValue({
                ok: false,
                statusText: 'Not Found'
            });

            await expect(checkUserPhoto(fakeImageUrl)).rejects.toThrow('Failed to fetch image from S3: Not Found');
        });
    });

    describe('handling errors', () => {

        it('should throw error if no image data provided', async () => {
            await expect(checkUserPhoto(null)).rejects.toThrow('No image data available');
        });

        it('should throw error if Vertex AI is unavailable', async () => {
            mockGenerateContent.mockRejectedValue(new Error('Vertex AI unavailable'));

            await expect(checkUserPhoto(fakeImageUrl)).rejects.toThrow('Vertex AI unavailable');
        });

        it('should throw error if AI response contains invalid JSON', async () => {
            mockGenerateContent.mockResolvedValue({
                response: {
                    candidates: [{
                        content: { parts: [{ text: 'not valid json {{' }] }
                    }]
                }
            });

            await expect(checkUserPhoto(fakeImageUrl)).rejects.toThrow();
        });
    });
});
