import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/geoapifyService.mjs', () => ({
    fetchRecyclingPlaces: vi.fn()
}));

vi.mock('../mappers/pointMapper.mjs', () => ({
    pointMapper: vi.fn()
}));

import { getRecyclingPoints } from '../handlers/getRecyclingPoints.mjs';
import { fetchRecyclingPlaces } from '../services/geoapifyService.mjs';
import { pointMapper } from '../mappers/pointMapper.mjs';

const makeEvent = (overrides = {}) => ({
    queryStringParameters: { lat: '50.45466', lon: '30.5238', materials: 'glass', ...overrides }
});

describe('getRecyclingPoints', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('missing parameters in request', () => {

        it('should return 400 if lat is missing', async () => {
            const result = await getRecyclingPoints(makeEvent({ lat: undefined }));

            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if lon is missing', async () => {
            const result = await getRecyclingPoints(makeEvent({ lon: undefined }));

            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if materials is missing', async () => {
            const result = await getRecyclingPoints(makeEvent({ materials: undefined }));

            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if queryStringParameters is null', async () => {
            const result = await getRecyclingPoints({ queryStringParameters: null });

            expect(result.statusCode).toBe(400);
        });
    });

    describe('successful response', () => {

        it('should return 200 with count and points', async () => {
            const fakeRaw = { features: [{ id: 'place_001', lat: 50.45466, lon: 30.5238 }] };
            const fakePoints = [{ id: 'place_001', lat: 50.45466, lon: 30.5238 }];
            fetchRecyclingPlaces.mockResolvedValue(fakeRaw);
            pointMapper.mockReturnValue(fakePoints);

            const result = await getRecyclingPoints(makeEvent());

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({ count: 1, points: fakePoints });
        });

        it('should use default radius 2000 if not provided', async () => {
            fetchRecyclingPlaces.mockResolvedValue({});
            pointMapper.mockReturnValue([]);

            await getRecyclingPoints(makeEvent());

            expect(fetchRecyclingPlaces).toHaveBeenCalledWith(
                expect.objectContaining({ radius: 2000 })
            );
        });
    });

    describe('not found', () => {

        it('should return 404 if pointMapper returns null', async () => {
            fetchRecyclingPlaces.mockResolvedValue({});
            pointMapper.mockReturnValue(null);

            const result = await getRecyclingPoints(makeEvent());

            expect(result.statusCode).toBe(404);
        });
    });

    describe('handling errors', () => {

        it('should return 500 if fetchRecyclingPlaces throws', async () => {
            fetchRecyclingPlaces.mockRejectedValue(new Error('Internal Server Error'));

            const result = await getRecyclingPoints(makeEvent());

            expect(result.statusCode).toBe(500);
        });
    });
});
