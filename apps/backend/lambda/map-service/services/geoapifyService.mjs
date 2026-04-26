import { makeRequest } from "../helpers/makeRequest.mjs";

const GEOAPIFY_KEY = process.env.GEOAPIFY_KEY;

export async function fetchRecyclingPlaces({ lat, lon, radius }) {
    const categories = 'service.recycling';
    const filter = `circle:${lon},${lat},${radius}`;
    const bias = `proximity:${lon},${lat}`;
    const limit = 100;

    const url = `https://api.geoapify.com/v2/places?categories=${categories}&filter=${filter}&bias=${bias}&limit=${limit}&apiKey=${GEOAPIFY_KEY}`;

    return await makeRequest(url);
}

export async function fetchRoute({ fromLat, fromLon, toLat, toLon, mode = 'walk' }) {
    const waypoints = `${fromLat},${fromLon}|${toLat},${toLon}`;

    const url = `https://api.geoapify.com/v1/routing?waypoints=${waypoints}&mode=${mode}&apiKey=${GEOAPIFY_KEY}`;

    return await makeRequest(url);
}
