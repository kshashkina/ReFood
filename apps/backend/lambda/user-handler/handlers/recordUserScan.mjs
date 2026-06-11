import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { recordScan } from '../services/scansDatabase.mjs';
import { invokeMetrics } from '../services/metricsService.mjs';

export async function recordUserScan(event) {
    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (!userId) {
            return response(401, { error: "User not recognized" });
        }

        const body = JSON.parse(event.body || '{}');
        const { barcode, productName, productBrand, image, productVersion } = body;

        if (!barcode) {
            return response(400, { error: "barcode is required" });
        }

        await Promise.all([
            recordScan(userId, { barcode, productName, productBrand, image, productVersion }),
            invokeMetrics('increment_scanned', userId)
        ]);

        return response(201, { success: true });
    } catch (error) {
        console.error("Error:", error);
        return response(500, { error: "Failed to record scan" });
    }
}
