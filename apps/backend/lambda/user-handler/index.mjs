import { registerUser } from "./handlers/registerUser.mjs";
import { registerLinkAccount } from "./handlers/registerLinkAccount.mjs";
import { getDashboard } from "./handlers/getUserDashboard.mjs";
import { getUserScanHistory } from "./handlers/getUserScanHistory.mjs";
import { deleteUserData } from "./handlers/deleteUserFromDatabase.mjs";
import { showProductsFavorites } from "./handlers/showProductsFavorites.mjs";
import { getAchievements } from "./handlers/getAchievements.mjs";
import { response, optionsResponse } from "./helpers/response.mjs";

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    console.log(`UserRequest: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'POST') {
            if (path.endsWith('/users/register')) {
                return await registerUser(event);
            }
            if (path.endsWith('/users/register/link-account')) {
                return await registerLinkAccount(event);
            }
        }

        if (method === 'GET') {
            if (path.endsWith('/users/dashboard')) {
                return await getDashboard(event);
            }

            if (path.endsWith('/users/scans')) {
                return await getUserScanHistory(event);
            }

            if (path.endsWith('/users/favorites')) {
                return await showProductsFavorites(event);
            }

            if (path.endsWith('/users/achievements')) {
                return await getAchievements(event);
            }
        }

        if (method === 'DELETE' && path.endsWith('/users')) {
            return await deleteUserData(event);
        }

        return response(404, {
            error: "Route not found"
        });

    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Internal server error"
        });
    }
};
