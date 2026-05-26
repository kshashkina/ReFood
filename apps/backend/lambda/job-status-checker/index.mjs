import { response, optionsResponse } from './helpers/response.mjs';
import { checkValidationImageStatus } from './handlers/checkValidationImageStatus.mjs';

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    const pathParts = path.split('/').filter(part => part !== '');

    console.log(`Request: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'GET' && pathParts.includes('image-validation')) {
            return await checkValidationImageStatus(event);
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
