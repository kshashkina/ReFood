export async function makeRequest(url) {
    try {
        console.log(`Sending request to Geoapify: ${url}`);
        const res = await fetch(url);

        if (!res.ok) {
            const errorText = await res.text();
            console.error("Geoapify error:", errorText);
            throw new Error(`Geoapify status: ${res.status}`);
        }

        return res.json();
    } catch (error) {
        console.error("Geoapify error:", error);
        return null;
    }
}
