import { offProductToProduct } from '../mappers/productMapper.mjs';

const OFF_API_URL = "https://world.openfoodfacts.net/api/v2/product";
const USER_AGENT = "ReFood/1.0 (refood.dev@ukr.net)";

export async function fetchFromOpenFoodFacts(barcode) {
    const url = `${OFF_API_URL}/${barcode}.json`;

    try {
        const res = await fetch(url, {
            headers: {
                "User-Agent": USER_AGENT,
                Accept: "application/json",
            },
        });

        if (!res.ok) {
            console.error(`OFF API returned ${res.status}`);
            return null;
        }

        const data = await res.json();
        if (data.status !== 1) return null;

        const product = data.product || {};
        const barcodeFromAPI = product.barcode || product.code || data.code || barcode;

        return offProductToProduct(barcodeFromAPI, product);
    } catch (error) {
        console.error("OFF API Error:", error);
        return null;
    }
}
