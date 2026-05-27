import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { invokeMetricsSync } from '../services/metricsService.mjs';

export const getAchievements = async (event) => {
    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (!userId) {
            return response(401, { error: "User not recognized" });
        }

        const result = await invokeMetricsSync('get_achievements', userId);

        if (!result?.success) {
            return response(500, { error: "Failed to load achievements" });
        }

        return response(200, {
            achievements: result.achievements,
            totalUnlocked: result.totalUnlocked,
            total: result.total
        });

    } catch (error) {
        console.error("Error:", error);
        return response(500, { error: "Failed to load achievements" });
    }
};
