import { describe, it, expect } from 'vitest';
import { pointMapper } from '../mappers/pointMapper.mjs';

const makePoint = (overrides = {}) => ({
    properties: {
        place_id: 'place_001',
        lat: 50.45466,
        lon: 30.5238,
        name: 'Green Point',
        address_line1: 'Address 1',
        operator: 'Eco Operator',
        recycling_options: {
            glass: true,
            plastic: true,
            paper: false
        },
        ...overrides
    }
});

const fakeData = (points) => ({ features: points });

describe('pointMapper', () => {

    describe('invalid or empty point data', () => {

        it('should return null if data has no features', () => {
            expect(pointMapper({}, ['all'])).toBeNull();
            expect(pointMapper(null, ['all'])).toBeNull();
        });

        it('should return empty array if no features match the material filter', () => {
            const data = fakeData([makePoint()]);
            const result = pointMapper(data, ['nonexistent_material']);

            expect(result).toEqual([]);
        });
    });

    describe('material filtering', () => {

        it('should return all points when material is marked as all', () => {
            const data = fakeData([makePoint(), makePoint()]);
            const result = pointMapper(data, ['all']);

            expect(result).toHaveLength(2);
        });

        it('should filter points by specified material', () => {
            const data = fakeData([makePoint(), makePoint({ recycling_options: { paper: true } })]);
            const result = pointMapper(data, ['glass']);

            expect(result).toHaveLength(1);
        });

        it('should filter by glass material', () => {
            const data = fakeData([makePoint(), makePoint({ recycling_options: { glass_bottles: true } })]);
            const result = pointMapper(data, ['glass']);

            expect(result).toHaveLength(2);
        });

        it('should match multiple requested materials', () => {
            const data = fakeData([
                makePoint({ recycling_options: { glass: true } }),
                makePoint({ recycling_options: { paper: true } }),
                makePoint({ recycling_options: { plastic: true } })
            ]);
            const result = pointMapper(data, ['glass', 'paper']);

            expect(result).toHaveLength(2);
        });
    });

    describe('mapped point structure', () => {

        it('should return point with correct fields', () => {
            const data = fakeData([makePoint()]);
            const result = pointMapper(data, ['all']);

            expect(result[0]).toMatchObject({
                id: 'place_001',
                lat: 50.45466,
                lon: 30.5238,
                name: 'Green Point',
                info: {
                    address: 'Address 1',
                    operator: 'Eco Operator',
                    brand: null,
                    website: null,
                    opening_hours: null,
                    wheelchair: null,
                    postcode: null
                },
                details: {
                    accepted_materials: ['glass', 'plastic'],
                    description: null
                }
            });
        });

        it('should use placeholder name as Recycling Point if name is missing', () => {
            const data = fakeData([makePoint({ name: undefined })]);
            const result = pointMapper(data, ['all']);

            expect(result[0].name).toBe('Recycling Point');
        });

        it('should use placeholder address as No address if address lines are missing', () => {
            const data = fakeData([makePoint({ address_line1: undefined, address_line2: undefined })]);
            const result = pointMapper(data, ['all']);

            expect(result[0].info.address).toBe('No address');
        });
    });
});
