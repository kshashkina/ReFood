import { buildOverpassQuery } from "../helpers/overpassQueryBuilder.mjs";
import { fetchFromOverpass } from "../services/overpassService.mjs";
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
                message: "Missing required parameters: lat, lon and materials are required." 
            });
        }

        const materialsArray = materials.split(',').map(m => m.trim());
        const query = buildOverpassQuery({ 
            materials: materialsArray, 
            lat, 
            lon, 
            radius 
        });

        const points = await fetchFromOverpass(query);

        if (!points) {
            return response(502, { 
                message: "Error fetching data from Overpass API" 
            });
        }

        return response(200, { 
            count: points.length,
            points: points
        });
    } catch (error) {
        console.error("Error occurred", error);
        return response(500, { 
            message: "Internal Server Error" 
        });
    }
}
