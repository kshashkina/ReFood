const GEOAPIFY_KEY = process.env.GEOAPIFY_KEY;
const GEOAPIFY_URL = "https://api.geoapify.com/v2/places";

export async function fetchFromGeoapify({ lat, lon, radius }) {
    const categories = 'service.recycling';
    const filter = `circle:${lon},${lat},${radius}`;
    const bias = `proximity:${lon},${lat}`;
    const limit = 100;

    const url = `${GEOAPIFY_URL}?categories=${categories}&filter=${filter}&bias=${bias}&limit=${limit}&apiKey=${GEOAPIFY_KEY}`;

    try {
        console.log(`Query to Geoapify: ${url}`);
        const res = await fetch(url);
        
        if (!res.ok) {
            const errorText = await res.text();
            console.error("Geoapify Error Response:", errorText);
            throw new Error(`Geoapify: ${res.status}`);
        }

        const data = await res.json();
        return data.features || [];
    } catch (error) {
        console.error("Error with Geoapify:", error);
        return null;
    }
}
