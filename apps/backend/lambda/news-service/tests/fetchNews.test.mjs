import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/fetchPubMedApi.mjs', () => ({
    fetchNewsFromPubMed: vi.fn()
}));

vi.mock('../services/newsDatabase.mjs', () => ({
    checkNewsExists: vi.fn(),
    saveNewsToDb: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    processNewsWithAI: vi.fn()
}));

import { fetchNews } from '../handlers/fetchNews.mjs';
import { fetchNewsFromPubMed } from '../services/fetchPubMedApi.mjs';
import { checkNewsExists, saveNewsToDb } from '../services/newsDatabase.mjs';
import { processNewsWithAI } from '../services/aiService.mjs';

const fakeArticle = (id = '001') => ({
    id: `pmid-${id}`,
    title: 'Article about nutrition',
    abstract: 'Abstract about nutrition',
    date: '2025-05-01',
    resource: 'Journal of Nutrition'
});

const fakeAiResult = (id = 'pmid-001') => ({
    id,
    original_title_en: 'Original title EN',
    original_title_ua: 'Оригінальна назва UA',
    simplified_title_en: 'Simple title EN',
    simplified_title_ua: 'Простий заголовок UA',
    takeaway_en: 'Some takeaway',
    takeaway_ua: 'Деякий висновок'
});

describe('fetchNews', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('when PubMed returns no articles', () => {

        it('should return message "No researches found"', async () => {
            fetchNewsFromPubMed.mockResolvedValue([]);

            const result = await fetchNews();

            expect(result.message).toBe('No researches found');
            expect(processNewsWithAI).not.toHaveBeenCalled();
        });
    });

    describe('when all articles already exist in DB', () => {

        it('should return message that all articles are already in DB', async () => {
            fetchNewsFromPubMed.mockResolvedValue([fakeArticle('001'), fakeArticle('002')]);
            checkNewsExists.mockResolvedValue(true);

            const result = await fetchNews();

            expect(result.message).toBe('All fetched news already exist in database');
            expect(processNewsWithAI).not.toHaveBeenCalled();
        });
    });

    describe('when new articles are found', () => {

        it('should call processNewsWithAI and saveNewsToDb only with new articles', async () => {
            fetchNewsFromPubMed.mockResolvedValue([fakeArticle('001'), fakeArticle('002')]);
            checkNewsExists
                .mockResolvedValueOnce(true)
                .mockResolvedValueOnce(false);
            processNewsWithAI.mockResolvedValue({ processed_news: [fakeAiResult('002')] });
            saveNewsToDb.mockResolvedValue();

            const result = await fetchNews();

            expect(processNewsWithAI).toHaveBeenCalledWith([fakeArticle('002')]);
            expect(saveNewsToDb).toHaveBeenCalledTimes(1);
            expect(result.message).toContain('Successfully processed');
        });
    });

    describe('handling errors', () => {

        it('should throw if processNewsWithAI fails', async () => {
            fetchNewsFromPubMed.mockResolvedValue([fakeArticle('001')]);
            checkNewsExists.mockResolvedValue(false);
            processNewsWithAI.mockRejectedValue(new Error('AIService invocation failed'));

            await expect(fetchNews()).rejects.toThrow('AIService invocation failed');
        });

        it('should throw if saveNewsToDb fails', async () => {
            fetchNewsFromPubMed.mockResolvedValue([fakeArticle('001')]);
            checkNewsExists.mockResolvedValue(false);
            processNewsWithAI.mockResolvedValue({ processed_news: [fakeAiResult('001')] });
            saveNewsToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(fetchNews()).rejects.toThrow('DynamoDB unavailable');
        });
    });
});
