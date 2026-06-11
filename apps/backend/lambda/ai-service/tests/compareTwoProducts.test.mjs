import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockGenerateContent } = vi.hoisted(() => ({
    mockGenerateContent: vi.fn()
}));

vi.mock('../services/vertexai.mjs', () => ({
    getModel: vi.fn(() => ({
        generateContent: mockGenerateContent
    }))
}));

import { compareTwoProducts } from '../actions/compareTwoProducts.mjs';

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

const milkA = { barcode: '111111111111', name: 'Milk 2.5%', calories: 52, fat: 2.5 };
const milkB = { barcode: '222222222222', name: 'Milk 3.2%', calories: 60, fat: 3.2 };

describe('compareTwoProducts', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful comparison', () => {

        it('should return parsed AI response', async () => {
            const fakeComparison = {
                comparison_en: 'English comparison description',
                comparison_ua: 'Українське порівняння',
                winner_barcode: '111111111111',
                key_differences_en: ['Lower in calories in A', 'Higher in protein in B'],
                key_differences_ua: ['Менше калорій в А', 'Більше білка в Б']
            };
            mockAIResponse(fakeComparison);

            const result = await compareTwoProducts(milkA, milkB);

            expect(result).toEqual(fakeComparison);
        });

        it('should call generateContent once', async () => {
            mockAIResponse({ winner_barcode: '111111111111' });

            await compareTwoProducts(milkA, milkB);

            expect(mockGenerateContent).toHaveBeenCalledTimes(1);
        });

        it('should wrap both products as product_a and product_b in prompt', async () => {
            mockAIResponse({ winner_barcode: '111111111111' });

            await compareTwoProducts(milkA, milkB);

            const calledWith = mockGenerateContent.mock.calls[0][0];
            const expectedInput = JSON.stringify({ product_a: milkA, product_b: milkB });
            expect(calledWith).toContain(expectedInput);
        });
    });

    describe('handling errors', () => {

        it('should throw error if Vertex AI is unavailable', async () => {
            mockGenerateContent.mockRejectedValue(new Error('Vertex AI unavailable'));

            await expect(compareTwoProducts(milkA, milkB)).rejects.toThrow('Vertex AI unavailable');
        });

        it('should throw error if AI response contains invalid JSON', async () => {
            mockGenerateContent.mockResolvedValue({
                response: {
                    candidates: [{
                        content: { parts: [{ text: 'not valid json {{' }] }
                    }]
                }
            });

            await expect(compareTwoProducts(milkA, milkB)).rejects.toThrow();
        });
    });
});
