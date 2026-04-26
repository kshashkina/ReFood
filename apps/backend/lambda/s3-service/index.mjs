import { getPresignedUrl } from './handlers/getPresignedUrl.mjs';
import { validateImage } from './handlers/validateImage.mjs';
import { finalizeUpload } from './handlers/finalizeUpload.mjs';
import { response } from './helpers/response.mjs';

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';
    
    console.log(`S3Service Request: ${method} ${path}`);

    try {
        if (method === 'GET' && path.endsWith('/upload-url')) {
            return await getPresignedUrl(event);
        }

        if (method === 'POST' && path.endsWith('/validate')) {
            return await validateImage(event);
        }

        if (method === 'POST' && path.endsWith('/finalize')) {
            return await finalizeUpload(event);
        }

        return response(404, { 
            error: "Route not found in S3Service" 
        });

    } catch (error) {
        console.error("Error:", error);
        return response(500, { 
            error: "Internal server error" 
        });
    }
};
