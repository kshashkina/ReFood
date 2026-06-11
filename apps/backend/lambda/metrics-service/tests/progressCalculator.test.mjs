import { describe, it, expect } from 'vitest';
import { calculateProgress, countUnlocked } from '../helpers/progressCalculator.mjs';
import { ACHIEVEMENTS } from '../helpers/achivementsConfig.mjs';

describe('calculateProgress', () => {

    describe('when metrics is null (new user)', () => {

        it('should return all achievements with current=0 and isUnlocked=false', () => {
            const result = calculateProgress(null);

            result.forEach(a => {
                expect(a.current).toBe(0);
                expect(a.isUnlocked).toBe(false);
                expect(a.unlockedAt).toBeNull();
            });
        });

        it('should return the same number of achievements as in config', () => {
            const result = calculateProgress(null);
            expect(result.length).toBe(ACHIEVEMENTS.length);
        });

        it('should include required fields for each achievement', () => {
            const result = calculateProgress(null);

            result.forEach(a => {
                expect(a).toHaveProperty('id');
                expect(a).toHaveProperty('title_en');
                expect(a).toHaveProperty('title_ua');
                expect(a).toHaveProperty('description_en');
                expect(a).toHaveProperty('description_ua');
                expect(a).toHaveProperty('goal');
                expect(a).toHaveProperty('current');
                expect(a).toHaveProperty('isUnlocked');
                expect(a).toHaveProperty('unlockedAt');
            });
        });
    });

    describe('numeric achievement type (as example - scannedCount)', () => {

        it('should set current from metrics value', () => {
            const result = calculateProgress({ scannedCount: 5 });
            const firstStep = result.find(a => a.id === 'first_step');

            expect(firstStep.current).toBe(1);
            expect(firstStep.isUnlocked).toBe(true);
        });

        it('should cap current at goal value', () => {
            const result = calculateProgress({ scannedCount: 9999 });
            const activeUser = result.find(a => a.id === 'active_user');

            expect(activeUser.current).toBe(10);
            expect(activeUser.isUnlocked).toBe(true);
        });

        it('should set current=0 if metric is missing', () => {
            const result = calculateProgress({});
            const firstStep = result.find(a => a.id === 'first_step');

            expect(firstStep.current).toBe(0);
            expect(firstStep.isUnlocked).toBe(false);
        });

        it('should set isUnlocked=false if current < goal', () => {
            const result = calculateProgress({ scannedCount: 3 });
            const activeUser = result.find(a => a.id === 'active_user');

            expect(activeUser.current).toBe(3);
            expect(activeUser.isUnlocked).toBe(false);
        });

        it('should set isUnlocked=true when current equals goal', () => {
            const result = calculateProgress({ scannedCount: 10 });
            const activeUser = result.find(a => a.id === 'active_user');

            expect(activeUser.current).toBe(10);
            expect(activeUser.isUnlocked).toBe(true);
        });
    });

    describe('boolean achievement type (as example - earlyBirdUnlocked)', () => {

        it('should set current=1 and isUnlocked=true when boolean=true', () => {
            const result = calculateProgress({ earlyBirdUnlocked: true });
            const earlyBird = result.find(a => a.id === 'early_bird');

            expect(earlyBird.current).toBe(1);
            expect(earlyBird.isUnlocked).toBe(true);
        });

        it('should set current=0 and isUnlocked=false when boolean=false', () => {
            const result = calculateProgress({ earlyBirdUnlocked: false });
            const earlyBird = result.find(a => a.id === 'early_bird');

            expect(earlyBird.current).toBe(0);
            expect(earlyBird.isUnlocked).toBe(false);
        });

        it('should set current=0 and isUnlocked=false when boolean metric is absent', () => {
            const result = calculateProgress({});
            const earlyBird = result.find(a => a.id === 'early_bird');

            expect(earlyBird.current).toBe(0);
            expect(earlyBird.isUnlocked).toBe(false);
        });

    });

    describe('unlockedAt field - timestamp', () => {

        it('should return unlockedAt timestamp for unlocked achievement', () => {
            const timestamp = '2025-05-15T10:00:00.000Z';
            const result = calculateProgress({
                scannedCount: 1,
                scannedCountUnlockedAt: timestamp
            });
            const firstStep = result.find(a => a.id === 'first_step');

            expect(firstStep.unlockedAt).toBe(timestamp);
        });

        it('should return unlockedAt=null if timestamp key is missing but unlocked', () => {
            const result = calculateProgress({ scannedCount: 1 });
            const firstStep = result.find(a => a.id === 'first_step');

            expect(firstStep.unlockedAt).toBeNull();
        });

        it('should return unlockedAt=null for locked achievements', () => {
            const result = calculateProgress({ scannedCount: 0 });
            const firstStep = result.find(a => a.id === 'first_step');

            expect(firstStep.unlockedAt).toBeNull();
        });
    });
});

describe('countUnlocked', () => {

    it('should return 0 if no achievements are unlocked', () => {
        const progress = [{ isUnlocked: false }, { isUnlocked: false }];
        expect(countUnlocked(progress)).toBe(0);
    });

    it('should correctly count unlocked achievements', () => {
        const progress = [
            { isUnlocked: true },
            { isUnlocked: false },
            { isUnlocked: true }
        ];
        expect(countUnlocked(progress)).toBe(2);
    });

    it('should return 0 for empty array', () => {
        expect(countUnlocked([])).toBe(0);
    });
});
