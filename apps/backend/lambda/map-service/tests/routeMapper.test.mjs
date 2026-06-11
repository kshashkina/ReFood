import { describe, it, expect } from 'vitest';
import { routeMapper } from '../mappers/routeMapper.mjs';

const makeRoute = (overrides = {}) => ({
    features: [{
        properties: {
            mode: 'walk',
            distance: 1500,
            distance_units: 'meters',
            time: 1082.4,
            legs: [{
                steps: [
                    { distance: 300, time: 180, instruction: { text: 'Move straight on street' } },
                    { distance: 1200, time: 900, instruction: { text: 'Turn left onto avenue' } }
                ]
            }],
            ...overrides
        },
        geometry: {
            coordinates: [[[30.5238, 50.45466], [30.5333, 50.4564]]]
        }
    }]
});

describe('routeMapper', () => {

    describe('invalid or empty route data', () => {

        it('should return null if data is null', () => {
            expect(routeMapper(null)).toBeNull();
        });

        it('should return null if features array is empty', () => {
            expect(routeMapper({ features: [] })).toBeNull();
        });

        it('should return null if data has no features key', () => {
            expect(routeMapper({})).toBeNull();
        });
    });

    describe('successful mapping', () => {

        it('should return correct fields', () => {
            const result = routeMapper(makeRoute());

            expect(result).toMatchObject({
                mode: 'walk',
                distance: 1500,
                distanceUnits: 'meters',
                time: 1082,
                steps: expect.any(Array),
                coordinates: expect.any(Array)
            });
            expect(result.time).toBe(1082);
            expect(Number.isInteger(result.time)).toBe(true);
        });

        it('should map steps with distance, time and instruction text', () => {
            const result = routeMapper(makeRoute());

            expect(result.steps).toHaveLength(2);
            expect(result.steps[0]).toMatchObject({
                distance: 300,
                time: 180,
                instruction: 'Move straight on street'
            });
            expect(result.steps[1]).toMatchObject({
                distance: 1200,
                time: 900,
                instruction: 'Turn left onto avenue'
            });
        });

        it('should return empty steps array if legs is missing', () => {
            const result = routeMapper(makeRoute({ legs: undefined }));

            expect(result.steps).toEqual([]);
        });
    });
});
