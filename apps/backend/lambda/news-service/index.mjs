import { fetchNews } from "./handlers/fetchNews.mjs";
import { getSummary } from "./handlers/getDailyDashboard.mjs";
import { response, optionsResponse } from "./helpers/response.mjs";

export const handler = async (event) => {
    if (event['detail-type'] === 'Scheduled Event' || event.source === 'aws.events') {
        console.log("Triggered by EventBridge: starting background fetch");
        return await fetchNews();
    }

    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';
    const pathParts = path.split('/').filter(part => part !== '');
    console.log(`Request: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'GET' && pathParts.includes('daily-dashboard')) {
            return await getSummary(event);
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
