import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../services/geoapifyService.mjs', () => ({
    fetchRoute: vi.fn()
}));

vi.mock('../mappers/routeMapper.mjs', () => ({
    routeMapper: vi.fn()
}));

vi.mock('../services/usersDatabase.mjs', () => ({
    findUserIdByAnyMethod: vi.fn()
}));

vi.mock('../services/metricsService.mjs', () => ({
    invokeMetrics: vi.fn()
}));

vi.mock('../helpers/auth/identity.mjs', () => ({
    getRequestIdentity: vi.fn()
}));

import { getRoute } from '../handlers/getRoute.mjs';
import { fetchRoute } from '../services/geoapifyService.mjs';
import { routeMapper } from '../mappers/routeMapper.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { invokeMetrics } from '../services/metricsService.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';

const makeEvent = (overrides = {}) => ({
    queryStringParameters: {
        fromLat: '50.45466',
        fromLon: '30.5238',
        toLat: '50.4447',
        toLon: '30.5206',
        ...overrides
    }
});

const fakeRoute = {
    mode: 'walk',
    distance: 1500,
    distanceUnits: 'meters',
    time: 1082,
    steps: [],
    coordinates: []
};

describe('getRoute', () => {

    beforeEach(() => {
        vi.clearAllMocks();
        getRequestIdentity.mockReturnValue({ sub: 'identity-001' });
        findUserIdByAnyMethod.mockResolvedValue('user-001');
        invokeMetrics.mockResolvedValue();
    });

    describe('missing parameters in request', () => {

        it('should return 400 if fromLat is missing', async () => {
            const result = await getRoute(makeEvent({ fromLat: undefined }));
            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if fromLon is missing', async () => {
            const result = await getRoute(makeEvent({ fromLon: undefined }));
            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if toLat is missing', async () => {
            const result = await getRoute(makeEvent({ toLat: undefined }));
            expect(result.statusCode).toBe(400);
        });

        it('should return 400 if toLon is missing', async () => {
            const result = await getRoute(makeEvent({ toLon: undefined }));
            expect(result.statusCode).toBe(400);
        });
    });

    describe('successful route', () => {

        it('should return 200 with mapped route', async () => {
            fetchRoute.mockResolvedValue({});
            routeMapper.mockReturnValue(fakeRoute);

            const result = await getRoute(makeEvent());

            expect(result.statusCode).toBe(200);
            expect(JSON.parse(result.body)).toMatchObject({
                mode: 'walk',
                distance: 1500,
                distanceUnits: 'meters',
                time: 1082,
                steps: [],
                coordinates: []
            });
        });

        it('should use default mode walk if not provided', async () => {
            fetchRoute.mockResolvedValue({});
            routeMapper.mockReturnValue(fakeRoute);

            await getRoute(makeEvent());

            expect(fetchRoute).toHaveBeenCalledWith(
                expect.objectContaining({ mode: 'walk' })
            );
        });

        it('should use provided mode if specified', async () => {
            fetchRoute.mockResolvedValue({});
            routeMapper.mockReturnValue(fakeRoute);

            await getRoute(makeEvent({ mode: 'bicycle' }));

            expect(fetchRoute).toHaveBeenCalledWith(
                expect.objectContaining({ mode: 'bicycle' })
            );
        });

        it('should call invokeMetrics for track_map_check and increment_sorted', async () => {
            fetchRoute.mockResolvedValue({});
            routeMapper.mockReturnValue(fakeRoute);

            await getRoute(makeEvent());

            expect(invokeMetrics).toHaveBeenCalledWith('increment_sorted', 'user-001');
            expect(invokeMetrics).toHaveBeenCalledWith('track_map_check', 'user-001');
        });
    });

    describe('required route not found', () => {

        it('should return 404 if routeMapper returns null', async () => {
            fetchRoute.mockResolvedValue({});
            routeMapper.mockReturnValue(null);

            const result = await getRoute(makeEvent());

            expect(result.statusCode).toBe(404);
        });
    });

    describe('handling errors', () => {

        it('should return 500 if fetchRoute throws', async () => {
            fetchRoute.mockRejectedValue(new Error('Internal Server Error'));

            const result = await getRoute(makeEvent());

            expect(result.statusCode).toBe(500);
        });
    });
});
