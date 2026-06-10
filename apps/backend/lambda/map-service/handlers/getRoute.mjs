import { fetchRoute } from "../services/geoapifyService.mjs";
import { routeMapper } from "../mappers/routeMapper.mjs";
import { response } from "../helpers/response.mjs";
import { findUserIdByAnyMethod } from "../services/usersDatabase.mjs";
import { invokeMetrics } from "../services/metricsService.mjs";
import { getRequestIdentity } from "../helpers/auth/identity.mjs";

export async function getRoute(event) {
    try {
        const params = event.queryStringParameters || {};
        const fromLat = params.fromLat;
        const fromLon = params.fromLon;
        const toLat = params.toLat;
        const toLon = params.toLon;
        const mode = params.mode;

        if (!fromLat || !fromLon || !toLat || !toLon) {
            return response(400, {
                message: 'Missing required parameters: fromLat, fromLon, toLat, toLon'
            });
        }

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

        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);
        invokeMetrics('track_map_check', userId);

        return response(200, route);
    } catch (error) {
        console.error("Error occurred", error);
        return response(500, { message: "Internal Server Error" });
    }
}
