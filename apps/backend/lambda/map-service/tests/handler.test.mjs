import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../handlers/getRecyclingPoints.mjs', () => ({
    getRecyclingPoints: vi.fn()
}));

vi.mock('../handlers/getRoute.mjs', () => ({
    getRoute: vi.fn()
}));

import { handler } from '../index.mjs';
import { getRecyclingPoints } from '../handlers/getRecyclingPoints.mjs';
import { getRoute } from '../handlers/getRoute.mjs';

describe('map-service handler', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('GET /locations', () => {

        it('should call getRecyclingPoints and return its response', async () => {
            getRecyclingPoints.mockResolvedValue({ statusCode: 200, body: '{}' });

            const event = { httpMethod: 'GET', path: '/map/locations' };
            const result = await handler(event);

            expect(getRecyclingPoints).toHaveBeenCalledWith(event);
            expect(result.statusCode).toBe(200);
        });
    });

    describe('GET /route', () => {

        it('should call getRoute and return its response', async () => {
            getRoute.mockResolvedValue({ statusCode: 200, body: '{}' });

            const event = { httpMethod: 'GET', path: '/map/route' };
            const result = await handler(event);

            expect(getRoute).toHaveBeenCalledWith(event);
            expect(result.statusCode).toBe(200);
        });
    });

    describe('unknown routes', () => {

        it('should return 404 for unknown GET path', async () => {
            const result = await handler({ httpMethod: 'GET', path: '/map/unknown' });
            expect(result.statusCode).toBe(404);
        });
    });

    describe('handling errors', () => {

        it('should return 500 if getRecyclingPoints throws', async () => {
            getRecyclingPoints.mockRejectedValue(new Error('Internal server error'));

            const result = await handler({ httpMethod: 'GET', path: '/map/locations' });

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Internal server error' });
        });

        it('should return 500 if getRoute throws', async () => {
            getRoute.mockRejectedValue(new Error('Internal server error'));

            const result = await handler({ httpMethod: 'GET', path: '/map/route' });

            expect(result.statusCode).toBe(500);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Internal server error' });
        });
    });
});
