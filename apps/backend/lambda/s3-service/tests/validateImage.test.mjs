import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/uploadJobsDatabase.mjs', () => ({
    updateJobStatus: vi.fn(),
    createPendingJob: vi.fn()
}));

vi.mock('../services/aiService.mjs', () => ({
    checkPhoto: vi.fn()
}));

import { validateImage } from '../handlers/validateImage.mjs';
import { updateJobStatus } from '../services/uploadJobsDatabase.mjs';
import { checkPhoto } from '../services/aiService.mjs';

const makeEvent = (keys = ['temp/img-001.jpg']) => ({
    Records: keys.map(key => ({
        eventSource: 'aws:s3',
        s3: { object: { key } }
    }))
});

describe('validateImage', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('successful validation', () => {

        it('should set status APPROVED if AI returns isValid=true', async () => {
            checkPhoto.mockResolvedValue({ isValid: true });
            updateJobStatus.mockResolvedValue();

            const result = await validateImage(makeEvent());

            expect(result.results[0].status).toBe('APPROVED');
            expect(updateJobStatus).toHaveBeenCalledWith('img-001', 'APPROVED', null, null);
        });

        it('should set status REJECTED if AI returns isValid=false', async () => {
            checkPhoto.mockResolvedValue({ isValid: false, error_en: 'Not food', error_ua: 'Не їжа' });
            updateJobStatus.mockResolvedValue();

            const result = await validateImage(makeEvent());

            expect(result.results[0].status).toBe('REJECTED');
            expect(updateJobStatus).toHaveBeenCalledWith('img-001', 'REJECTED', 'Not food', 'Не їжа');
        });

        it('should process multiple records', async () => {
            checkPhoto.mockResolvedValue({ isValid: true });
            updateJobStatus.mockResolvedValue();

            const result = await validateImage(makeEvent(['temp/img-001.jpg', 'temp/img-002.jpg']));

            expect(result.processed).toBe(2);
            expect(result.results).toHaveLength(2);
        });
    });

    describe('handling errors', () => {

        it('should return error message if AI is unavailable', async () => {
            checkPhoto.mockRejectedValue(new Error('AI unavailable'));
            updateJobStatus.mockResolvedValue();

            const result = await validateImage(makeEvent());

            expect(result.results[0].error).toBe('AI unavailable');
        });
    });
});
