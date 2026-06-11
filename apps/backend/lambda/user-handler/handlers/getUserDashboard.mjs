import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getUserScans } from '../services/scansDatabase.mjs';
import { toScanListResponse } from '../mappers/scanMapper.mjs';
import { invokeMetrics, invokeMetricsSync } from '../services/metricsService.mjs';

export async function getDashboard(event) {
    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (!userId) {
            return response(401, {
                error: "User not recognized"
            });
        }

        invokeMetrics('update_streak', userId);

        const [counts, recentScans] = await Promise.all([
            invokeMetricsSync('get_counts', userId),
            getUserScans(userId, 5)
        ]);

        if (!counts || !recentScans) {
            return response(404, {
                error: "User data not found"
            });
        }

        return response(200, {
            profile: {
                scannedCount: counts?.scannedCount ?? 0,
                sortedCount: counts?.sortedCount ?? 0
            },
            recentScans: toScanListResponse(recentScans)
        });

    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Failed to load dashboard data"
        });
    }
}