import { getRequestIdentity } from "../helpers/auth/identity.mjs";
import { findUserIdByAnyMethod } from "../services/usersDatabase.mjs";
import { invokeMetrics } from "../services/metricsService.mjs";
import { response } from "../helpers/response.mjs";

export async function trackSorted(event) {
    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (!userId) {
            return response(401, {
                error: "Unauthorized"
            });
        }

        await invokeMetrics('increment_sorted', userId);
        await invokeMetrics('track_map_check', userId);

        return response(200, {
            message: "Sorted metrics tracked successfully"
        });
    } catch (error) {
        console.error("Error occurred", error);
        return response(500, { message: "Internal Server Error" });
    }
}
