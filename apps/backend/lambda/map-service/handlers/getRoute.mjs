import { fetchRoute } from "../services/geoapifyService.mjs";
import { routeMapper } from "../mappers/routeMapper.mjs";
import { response } from "../helpers/response.mjs";

export async function getRoute(event) {
    const { fromLat, fromLon, toLat, toLon, mode } = event.queryStringParameters || {};

    if (!fromLat || !fromLon || !toLat || !toLon) {
        return response(400, {
            message: 'Missing required query params: fromLat, fromLon, toLat, toLon'
        });
    }

    try {
        const rawData = await fetchRoute({
            fromLat,
            fromLon,
            toLat,
            toLon,
            mode: mode || 'walk'
        });

        const route = routeMapper(rawData);

        if (!route) {
            return response(404, {
                message: 'Route not found'
            });
        }

        return response(200, route);
    } catch (error) {
        console.error("Error occurred", error);
        return response(500, { message: "Internal Server Error" });
    }
}
