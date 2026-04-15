import { getLatestProductFromDB, saveProductToDB } from '../services/database.mjs';
import { fetchFromOpenFoodFacts } from '../services/fetchOffApi.mjs';
import { translateProduct } from '../services/aiService.mjs';
import { toProductResponse } from '../mappers/productMapper.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { response } from '../helpers/response.mjs';

export async function getProduct(event) {
    const barcodeRaw = event.pathParameters?.barcode;
    const barcode = normalizeBarcode(barcodeRaw);

    if (!barcode) {
        return response(400, { error: "Invalid barcode format" });
    }

    const dbProduct = await getLatestProductFromDB(barcode);

    if (dbProduct) {
        console.log(`Found product in DB for barcode: ${barcode}`);
        return response(200, {
            source: "local",
            product: dbProduct
        });
    }

    console.log(`DB miss, fetching from OFF: ${barcode}`);
    const offProduct = await fetchFromOpenFoodFacts(barcode);

    if (!offProduct) {
        return response(404, {
            error: "Product not found"
        });
    }

    const translated = await translateProduct(offProduct);

    const { categories_tags, allergens_tags, ingredients_text, packaging, ...baseProduct } = offProduct;
    const cleanProduct = { ...baseProduct, ...translated };

    await saveProductToDB(cleanProduct);

    return response(200, {
        source: "openfoodfacts",
        product: toProductResponse(cleanProduct),
    });
}
