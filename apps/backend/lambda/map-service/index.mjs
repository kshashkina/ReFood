import { getRecyclingPoints } from './handlers/getRecyclingPoints.mjs';
import { getRoute } from './handlers/getRoute.mjs';
import { optionsResponse, response } from './helpers/response.mjs';

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    console.log(`Request: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'GET' && path.includes('locations')) {
            return await getRecyclingPoints(event);
        }

        if (method === 'GET' && path.includes('route')) {
            return await getRoute(event);
        }

    return response(404, {
        error: "Route not found in MapService"
    });

    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Internal server error"
        });
    }
};
