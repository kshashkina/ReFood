import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { getLatestProductFromDB } from '../services/databases/productDatabase.mjs';
import { getFavorite, addFavorite, removeFavorite } from '../services/databases/productsFavoritesDatabase.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { response } from '../helpers/response.mjs';

export const addProductsFavorites = async (event) => {
    const identity = getRequestIdentity(event);
    const userId = await findUserIdByAnyMethod(identity);

    if (!userId) {
        return response(401, { error: "Unauthorized" });
    }

    const barcodeRaw = event.pathParameters?.barcode;
    const barcode = normalizeBarcode(barcodeRaw);

    if (!barcode) {
        return response(400, { error: "Invalid barcode" });
    }

    const existing = await getFavorite(userId, barcode);

    if (existing) {
        await removeFavorite(userId, barcode);
        return response(200, { liked: false });
    }

    const product = await getLatestProductFromDB(barcode);
    if (!product) {
        return response(404, {
            error: "Product not found in database"
        });
    }

    await addFavorite(userId, product);
    return response(200, { liked: true });
};
