import { describe, it, expect } from 'vitest';
import { response, optionsResponse } from '../helpers/response.mjs';

describe('response', () => {

    describe('correct structure of response', () => {

        it('should return statusCode, headers and body', () => {
            const result = response(200, { status: 'PENDING' });

            expect(result).toHaveProperty('statusCode', 200);
            expect(result).toHaveProperty('headers');
            expect(result).toHaveProperty('body');
        });

        it('should include CORS headers', () => {
            const result = response(200, {});

            expect(result.headers['Access-Control-Allow-Origin']).toBe('*');
            expect(result.headers['Content-Type']).toBe('application/json');
        });
    });

    describe('status codes', () => {

        it('should return 200 with body', () => {
            const result = response(200, { status: 'PENDING' });
            expect(result.statusCode).toBe(200);
        });

        it('should return 400 with error body', () => {
            const result = response(400, { error: 'Missing imageId' });
            expect(result.statusCode).toBe(400);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Missing imageId' });
        });

        it('should return 404 with error body', () => {
            const result = response(404, { error: 'Job not found' });
            expect(result.statusCode).toBe(404);
            expect(JSON.parse(result.body)).toMatchObject({ error: 'Job not found' });
        });

        it('should return 500 with error body', () => {
            const result = response(500, { error: 'Internal server error' });
            expect(result.statusCode).toBe(500);
        });
    });
});

describe('optionsResponse correct structure of response', () => {

    it('should return statusCode 204, empty body and CORS headers', () => {
        const result = optionsResponse();

        expect(result.statusCode).toBe(204);
        expect(result.body).toBe('');
        expect(result.headers['Access-Control-Allow-Origin']).toBe('*');
    });
});
