import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { removeFavorite } from '../services/databases/productsFavoritesDatabase.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { response } from '../helpers/response.mjs';

export const removeProductFromFavorites = async (event) => {
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

    await removeFavorite(userId, barcode);
    return response(200, { liked: false });
};
