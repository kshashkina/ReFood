import { fetchRecyclingPlaces } from "../services/geoapifyService.mjs";
import { pointMapper } from "../mappers/pointMapper.mjs";
import { response } from "../helpers/response.mjs";

const RADIUS_DEFAULT = 2000;

export async function getRecyclingPoints(event) {
    try {
        const params = event.queryStringParameters || {};
        const lat = params.lat;
        const lon = params.lon;
        const materials = params.materials;
        const radius = params.radius || RADIUS_DEFAULT;

        if (!lat || !lon || !materials) {
            return response(400, {
                error: "Missing required parameters: lat, lon and materials are required."
            });
        }

        const materialsArray = materials.split(',').map(m => m.trim());
        const rawData = await fetchRecyclingPlaces({
            lat,
            lon,
            radius
        });

        const points = pointMapper(rawData, materialsArray);

        if (!points) {
            return response(404, {
                error: 'Points not found'
            });
        }

        return response(200, {
            count: points.length,
            points: points
        });
    } catch (error) {
        console.error("Error occurred", error);
        return response(500, { error: "Internal Server Error" });
    }
}
