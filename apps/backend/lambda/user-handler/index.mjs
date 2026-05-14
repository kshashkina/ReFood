import { registerUser } from "./handlers/registerUser.mjs";
import { getDashboard } from "./handlers/getUserDashboard.mjs";
import { response, optionsResponse } from "./helpers/response.mjs";

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    console.log(`UserRequest: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'POST' && path.endsWith('/users/register')) {
            return await registerUser(event);
        }

        if (method === 'GET' && path.endsWith('/users/dashboard')) {
            return await getDashboard(event);
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
