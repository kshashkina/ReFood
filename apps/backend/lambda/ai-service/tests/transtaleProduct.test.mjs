import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockGenerateContent } = vi.hoisted(() => ({
    mockGenerateContent: vi.fn()
}));

vi.mock('../services/vertexai.mjs', () => ({
    getModel: vi.fn(() => ({
        generateContent: mockGenerateContent
    }))
}));

import { translateProduct } from '../actions/translateProduct.mjs';

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

describe('translateProduct', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful translation', () => {

        it('should return parsed AI response', async () => {
            const fakeTranslation = { allergens_en: 'Milk', allergens_ua: 'Молоко' };
            mockAIResponse(fakeTranslation);

            const result = await translateProduct({ allergens: 'Milk' });

            expect(result).toEqual(fakeTranslation);
        });

        it('should call vertexAi.getModel once', async () => {
            mockAIResponse({ allergens_en: 'Milk', allergens_ua: 'Молоко' });

            await translateProduct({ allergens: 'Milk' });

            expect(mockGenerateContent).toHaveBeenCalledTimes(1);
        });

        it('should include product data in the prompt', async () => {
            mockAIResponse({ allergens_en: 'Milk', allergens_ua: 'Молоко' });

            const data = { allergens: 'Milk' };
            await translateProduct(data);

            const calledWith = mockGenerateContent.mock.calls[0][0];
            expect(calledWith).toContain(JSON.stringify(data));
        });
    });

    describe('handling errors', () => {

        it('should throw error if Vertex AI is unavailable', async () => {
            mockGenerateContent.mockRejectedValue(new Error('Vertex AI unavailable'));

            await expect(translateProduct({ allergens: 'Milk' })).rejects.toThrow('Vertex AI unavailable');
        });

        it('should throw error if AI response contains invalid JSON', async () => {
            mockGenerateContent.mockResolvedValue({
                response: {
                    candidates: [{
                        content: { parts: [{ text: 'not valid json {{' }] }
                    }]
                }
            });

            await expect(translateProduct({ allergens: 'Milk' })).rejects.toThrow();
        });
    });
});
