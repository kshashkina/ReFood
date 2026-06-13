import { describe, it, expect } from 'vitest';
import { toScanResponse, toScanListResponse } from '../mappers/scanMapper.mjs';

const fakeScan = {
    barcode: '1234567890',
    productName: 'Test Product',
    image: 'https://example.com/img.jpg',
    timestamp: '2026-06-05T15:59:16.712Z'
};

describe('scanMapper', () => {

    describe('toScanResponse', () => {

        it('should map all fields correctly', () => {
            const result = toScanResponse(fakeScan);

            expect(result.barcode).toBe('1234567890');
            expect(result.name).toBe('Test Product');
            expect(result.image).toBe('https://example.com/img.jpg');
            expect(result.date).toBe('2026-06-05T15:59:16.712Z');
        });

        it('should handle null image', () => {
            const result = toScanResponse({ ...fakeScan, image: null });
            expect(result.image).toBeNull();
        });
    });

    describe('toScanListResponse', () => {

        it('should return an empty array for empty input', () => {
            const result = toScanListResponse([]);
            expect(result).toEqual([]);
        });

        it('should map each scan in the list', () => {
            const scans = [
                { barcode: '1234567890', productName: 'Milk', image: null, timestamp: '2026-06-05T15:59:16.712Z' },
                { barcode: '1234567889', productName: 'Bread', image: null, timestamp: '2026-06-01T19:48:45.012Z' }
            ];
            const result = toScanListResponse(scans);

            expect(result).toHaveLength(2);
            expect(result[0].barcode).toBe('1234567890');
            expect(result[1].barcode).toBe('1234567889');
        });
    });
});
