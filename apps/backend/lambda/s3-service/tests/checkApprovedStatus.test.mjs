import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/uploadJobsDatabase.mjs', () => ({
    getJobStatus: vi.fn()
}));

import { requireApprovedJob } from '../helpers/checkApprovedStatus.mjs';
import { getJobStatus } from '../services/uploadJobsDatabase.mjs';

describe('requireApprovedJob', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should return false with JOB_NOT_FOUND if no job exists', async () => {
        getJobStatus.mockResolvedValue(null);

        const result = await requireApprovedJob('img-001');

        expect(result.ok).toBe(false);
        expect(result.code).toBe('JOB_NOT_FOUND');
    });

    it('should return false with NOT_APPROVED if job status is REJECTED', async () => {
        getJobStatus.mockResolvedValue({ imageId: 'img-001', status: 'REJECTED' });

        const result = await requireApprovedJob('img-001');

        expect(result.ok).toBe(false);
        expect(result.code).toBe('NOT_APPROVED');
    });

    it('should return true with job if status is APPROVED', async () => {
        const fakeJob = { imageId: 'img-001', status: 'APPROVED' };
        getJobStatus.mockResolvedValue(fakeJob);

        const result = await requireApprovedJob('img-001');

        expect(result.ok).toBe(true);
        expect(result.job).toEqual(fakeJob);
    });

    it('should throw if getJobStatus throws', async () => {
        getJobStatus.mockRejectedValue(new Error('DynamoDB unavailable'));

        await expect(requireApprovedJob('img-001')).rejects.toThrow('DynamoDB unavailable');
    });
});
