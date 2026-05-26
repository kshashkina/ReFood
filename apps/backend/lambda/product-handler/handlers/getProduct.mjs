import { getLatestProductFromDB, saveProductToDB } from '../services/productDatabase.mjs';
import { fetchFromOpenFoodFacts } from '../services/fetchOffApi.mjs';
import { translateProduct } from '../services/aiService.mjs';
import { toProductResponse } from '../mappers/productMapper.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod, incrementUserScanCount } from '../services/usersDatabase.mjs';
import { recordScan } from '../services/scansDatabase.mjs';

export async function getProduct(event) {
    const barcodeRaw = event.pathParameters?.barcode;
    const barcode = normalizeBarcode(barcodeRaw);

    if (!barcode) {
        return response(400, { error: "Invalid barcode format" });
    }

    let product;
    let source = "local";

    const dbProduct = await getLatestProductFromDB(barcode);
    if (dbProduct) {
        console.log(`Found product in DB for barcode: ${barcode}`);
        product = dbProduct;
    } else {
        console.log(`DB miss, fetching from OFF: ${barcode}`);
        const offProduct = await fetchFromOpenFoodFacts(barcode);

        if (!offProduct) {
            return response(404, {
                error: "Product not found"
            });
        }

        const translated = await translateProduct(offProduct);
        const { categories_tags, allergens_tags, ingredients_text, packaging, ...baseProduct } = offProduct;
        product = { ...baseProduct, ...translated };
        source = "openfoodfacts";

        await saveProductToDB(product);
    }

    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (userId) {
            await Promise.all([
                incrementUserScanCount(userId),
                recordScan(userId, product)
            ]);
            console.log(`History updated for user: ${userId}`);
        } else {
            console.log("User not found or identity missing, skipping increment.");
        }
    } catch (authError) {
        console.error("Failed to increment scan count:", authError);
    }

    return response(200, {
        source: source,
        product: source === "local" ? product : toProductResponse(product),
    });
}
