import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod, getUserProfile } from '../services/usersDatabase.mjs';
import { getUserScans } from '../services/scansDatabase.mjs';
import { toScanListResponse } from '../mappers/scanMapper.mjs';

export async function getDashboard(event) {
    try {
        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);

        if (!userId) {
            return response(401, {
                error: "User not recognized"
            });
        }

        const [user, recentScans] = await Promise.all([
            getUserProfile(userId),
            getUserScans(userId, 5)
        ]);

        if (!user) {
            return response(404, {
                error: "User profile not found"
            });
        }

        return response(200, {
            profile: {
                scansCount: user.scansCount || 0,
                isPremium: user.isPremium || false
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