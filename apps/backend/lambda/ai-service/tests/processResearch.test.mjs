import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockGenerateContent } = vi.hoisted(() => ({
    mockGenerateContent: vi.fn()
}));

vi.mock('../services/vertexai.mjs', () => ({
    getModel: vi.fn(() => ({
        generateContent: mockGenerateContent
    }))
}));

import { processResearch } from '../actions/processResearch.mjs';

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

const fakeArticle = {
    id: '99999',
    title: 'Health benefits of fermented foods',
    abstract: 'This study examines the effect of probiotics on gut health.',
    resource: 'Journal of Nutrition',
    date: '2025-01-15'
};

describe('processResearch', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful processing', () => {

        it('should return parsed AI response', async () => {
            const fakeResult = {
                original_title_en: 'Health benefits of fermented foods',
                original_title_ua: 'Переваги ферментованих продуктів',
                simplified_title_en: 'Fermented foods improve gut health',
                simplified_title_ua: 'Ферментовані продукти покращують здоров\'я кишківника',
                takeaway_en: 'Some takeaway',
                takeaway_ua: 'Деякі виноси'
            };
            mockAIResponse(fakeResult);

            const result = await processResearch(fakeArticle);

            expect(result).toEqual(fakeResult);
        });

        it('should call generateContent once', async () => {
            mockAIResponse({ original_title_en: 'Some title', original_title_ua: 'Якийсь заголовок' });

            await processResearch(fakeArticle);

            expect(mockGenerateContent).toHaveBeenCalledTimes(1);
        });

        it('should include article data in the prompt', async () => {
            mockAIResponse({ original_title_en: 'Some title', original_title_ua: 'Якийсь заголовок' });

            await processResearch(fakeArticle);

            const calledWith = mockGenerateContent.mock.calls[0][0];
            expect(calledWith).toContain(JSON.stringify(fakeArticle));
        });
    });

    describe('handling errors', () => {

        it('should throw error if Vertex AI is unavailable', async () => {
            mockGenerateContent.mockRejectedValue(new Error('Vertex AI unavailable'));

            await expect(processResearch(fakeArticle)).rejects.toThrow('Vertex AI unavailable');
        });

        it('should throw error if AI response contains invalid JSON', async () => {
            mockGenerateContent.mockResolvedValue({
                response: {
                    candidates: [{
                        content: { parts: [{ text: 'not valid json {{' }] }
                    }]
                }
            });

            await expect(processResearch(fakeArticle)).rejects.toThrow();
        });
    });
});
