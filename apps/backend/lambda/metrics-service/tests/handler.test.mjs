import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/userMetricsDatabase.mjs', () => ({
    getMetrics: vi.fn(),
    incrementScanned: vi.fn(),
    incrementSorted: vi.fn(),
    updateStreak: vi.fn(),
    trackMapCheck: vi.fn(),
    incrementAddedProducts: vi.fn(),
    deleteMetrics: vi.fn()
}));

vi.mock('../helpers/progressCalculator.mjs', () => ({
    calculateProgress: vi.fn(),
    countUnlocked: vi.fn()
}));

import { handler } from '../index.mjs';
import { getMetrics, incrementScanned, incrementSorted, updateStreak, trackMapCheck, incrementAddedProducts, deleteMetrics } from '../services/userMetricsDatabase.mjs';
import { calculateProgress, countUnlocked } from '../helpers/progressCalculator.mjs';

const makeEvent = (action, userId = 'user-001') => ({ action, userId });

describe('metrics-service handler', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('input validation', () => {

        it('should return error if userId is missing', async () => {
            const result = await handler({ action: 'increment_scanned' });

            expect(result.success).toBe(false);
            expect(result.error).toContain('Missing userId');
        });

        it('should return error if action is missing', async () => {
            const result = await handler({ userId: 'user-001' });

            expect(result.success).toBe(false);
            expect(result.error).toContain('Unknown action');
        });

        it('should return error if action is unknown', async () => {
            const result = await handler(makeEvent('check_unknown'));

            expect(result.success).toBe(false);
            expect(result.error).toContain('check_unknown');
        });
    });

    describe('increment_scanned', () => {

        it('should call incrementScanned and return success=true', async () => {
            incrementScanned.mockResolvedValue();

            const result = await handler(makeEvent('increment_scanned'));

            expect(incrementScanned).toHaveBeenCalledWith('user-001', expect.objectContaining({
                hour: expect.any(Number),
                isWeekend: expect.any(Boolean)
            }));
            expect(result.success).toBe(true);
        });
    });

    describe('increment_sorted', () => {

        it('should call incrementSorted and return success=true', async () => {
            incrementSorted.mockResolvedValue();

            const result = await handler(makeEvent('increment_sorted'));

            expect(incrementSorted).toHaveBeenCalledWith('user-001');
            expect(result.success).toBe(true);
        });
    });

    describe('update_streak', () => {

        it('should call updateStreak and return success=true', async () => {
            updateStreak.mockResolvedValue();

            const result = await handler(makeEvent('update_streak'));

            expect(updateStreak).toHaveBeenCalledWith('user-001');
            expect(result.success).toBe(true);
        });
    });

    describe('track_map_check', () => {

        it('should call trackMapCheck and return success=true', async () => {
            trackMapCheck.mockResolvedValue();

            const result = await handler(makeEvent('track_map_check'));

            expect(trackMapCheck).toHaveBeenCalledWith('user-001', expect.objectContaining({
                hour: expect.any(Number),
                isWeekend: expect.any(Boolean)
            }));
            expect(result.success).toBe(true);
        });
    });

    describe('increment_product', () => {

        it('should call incrementAddedProducts and return success=true', async () => {
            incrementAddedProducts.mockResolvedValue();

            const result = await handler(makeEvent('increment_product'));

            expect(incrementAddedProducts).toHaveBeenCalledWith('user-001');
            expect(result.success).toBe(true);
        });
    });

    describe('get_achievements', () => {

        it('should return achievements list with totalUnlocked and total', async () => {
            const fakeMetrics = { scannedCount: 5 };
            const fakeProgress = [{ id: 'first_step', isUnlocked: true }];
            getMetrics.mockResolvedValue(fakeMetrics);
            calculateProgress.mockReturnValue(fakeProgress);
            countUnlocked.mockReturnValue(1);

            const result = await handler(makeEvent('get_achievements'));

            expect(result.success).toBe(true);
            expect(result.achievements).toEqual(fakeProgress);
            expect(result.totalUnlocked).toBe(1);
            expect(result.total).toBeGreaterThan(0);
        });

        it('should pass null metrics to calculateProgress if user has no metrics yet', async () => {
            getMetrics.mockResolvedValue(null);
            calculateProgress.mockReturnValue([]);
            countUnlocked.mockReturnValue(0);

            await handler(makeEvent('get_achievements'));

            expect(calculateProgress).toHaveBeenCalledWith(null);
        });
    });

    describe('delete_metrics', () => {

        it('should call deleteMetrics and return success=true', async () => {
            deleteMetrics.mockResolvedValue();

            const result = await handler(makeEvent('delete_metrics'));

            expect(deleteMetrics).toHaveBeenCalledWith('user-001');
            expect(result.success).toBe(true);
        });
    });

    describe('handling errors', () => {

        it('should return success=false if DB throws an error', async () => {
            incrementScanned.mockRejectedValue(new Error('DynamoDB unavailable'));

            const result = await handler(makeEvent('increment_scanned'));

            expect(result.success).toBe(false);
            expect(result.error).toBe('DynamoDB unavailable');
        });
    });
});
