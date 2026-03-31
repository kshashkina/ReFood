import { pointMapper } from '../mappers/pointMapper.mjs';

const OVERPASS_API_URL = "https://overpass.private.coffee/api/interpreter";
const USER_AGENT = "ReFood/1.0 (refood.dev@ukr.net) Student Diploma Project";

export async function fetchFromOverpass(query) {
    try {
        const res= await fetch(OVERPASS_API_URL, {
            method: 'POST',
            headers: {
                "User-Agent": USER_AGENT,
                Accept: "application/json",
            },
            body: `data=${encodeURIComponent(query)}`
        });

        if (!res.ok) {
            console.error(`Overpass API returned ${res.status}`);
            return null;
        }

        const data = await res.json();
        return pointMapper(data.elements || []);
    } catch (error) {
        console.error("Overpass API Error:", error);
        return null;
    }
}

