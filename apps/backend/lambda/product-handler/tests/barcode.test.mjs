import { describe, it, expect } from 'vitest';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';

describe('normalizeBarcode', () => {

    describe('invalid input', () => {

        it('should return null for null', () => {
            expect(normalizeBarcode(null)).toBeNull();
        });

        it('should return null for empty string', () => {
            expect(normalizeBarcode('')).toBeNull();
        });

        it('should return null for non-numeric string', () => {
            expect(normalizeBarcode('abcdefgh')).toBeNull();
        });

        it('should return null for barcode shorter than 7 digits', () => {
            expect(normalizeBarcode('123456')).toBeNull();
        });

        it('should return null for barcode longer than 14 digits', () => {
            expect(normalizeBarcode('123456789012345')).toBeNull();
        });

        it('should return null for mixed digits and letters', () => {
            expect(normalizeBarcode('1234abc890')).toBeNull();
        });
    });

    describe('8-digit barcodes (EAN-8)', () => {

        it('should return 8-digit barcode if exactly 8 digits', () => {
            expect(normalizeBarcode('12345678')).toBe('12345678');
        });

        it('should pad a 7-digit barcode to 8 digits', () => {
            expect(normalizeBarcode('1234567')).toBe('01234567');
        });
    });

    describe('13-digit barcodes (EAN-13)', () => {

        it('should return 13-digit barcode', () => {
            expect(normalizeBarcode('1234567890123')).toBe('1234567890123');
        });

        it('should pad a 9-digit (after stripping zeros) barcode to 13 digits', () => {
            expect(normalizeBarcode('000123456789')).toBe('0000123456789');
        });
    });

    describe('14-digit barcodes', () => {

        it('should return 14-digit barcode (no transformation)', () => {
            expect(normalizeBarcode('12345678901234')).toBe('12345678901234');
        });
    });
});
