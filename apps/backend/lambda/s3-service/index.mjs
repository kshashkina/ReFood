import { getPresignedUrl } from './handlers/getPresignedUrl.mjs';
import { validateImage } from './handlers/validateImage.mjs';
import { finalizeUpload } from './handlers/finalizeUpload.mjs';
import { response } from './helpers/response.mjs';

export const handler = async (event) => {
    if (event.Records?.[0]?.eventSource === 'aws:s3') {
        return await validateImage(event);
    }

    if (event.action === 'finalize_upload') {
        return await finalizeUpload(event);
    }

    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    console.log(`S3Service: HTTP ${method} ${path}`);

    try {
        if (method === 'GET' && path.endsWith('/upload-url')) {
            return await getPresignedUrl(event);
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

