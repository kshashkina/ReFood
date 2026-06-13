import { describe, it, expect } from 'vitest';
import { parseToGrams } from '../helpers/nutriments/parseToGrams.mjs';

describe('parseToGrams', () => {

    describe('various mass and volume representations', () => {

        it('should return the number if input is already a number', () => {
            expect(parseToGrams(200)).toBe(200);
        });

        it('should return null if input is null', () => {
            expect(parseToGrams(null)).toBeNull();
        });

        it('should return null if input is an empty string', () => {
            expect(parseToGrams('')).toBeNull();
        });

        it('should parse "200g" to 200', () => {
            expect(parseToGrams('200g')).toBe(200);
        });

        it('should parse "50 g" to 50', () => {
            expect(parseToGrams('50 g')).toBe(50);
        });

        it('should parse "1.5g" to 1.5', () => {
            expect(parseToGrams('1.5g')).toBe(1.5);
        });

        it('should parse "1kg" to 1000', () => {
            expect(parseToGrams('1kg')).toBe(1000);
        });

        it('should parse "0.5кг" to 500', () => {
            expect(parseToGrams('0.5кг')).toBe(500);
        });

        it('should parse "500mg" to 0.5', () => {
            expect(parseToGrams('500mg')).toBe(0.5);
        });

        it('should parse "250мг" to 0.25', () => {
            expect(parseToGrams('250мг')).toBe(0.25);
        });

        it('should parse "1l" to 1000', () => {
            expect(parseToGrams('1l')).toBe(1000);
        });

        it('should parse "250ml" as 250', () => {
            expect(parseToGrams('250ml')).toBe(250);
        });

        it('should return 0 for a non-numeric string', () => {
            expect(parseToGrams('abc')).toBe(0);
        });
    });
});
