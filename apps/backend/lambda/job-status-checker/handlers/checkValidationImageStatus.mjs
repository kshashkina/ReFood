import { response } from '../helpers/response.mjs';
import { getJobStatus } from '../services/uploadJobsDatabse.mjs';

export async function checkValidationImageStatus(event) {
    const imageId = event.pathParameters?.imageId || event.queryStringParameters?.imageId;

    if (!imageId) {
        return response(400, { error: "Missing imageId" });
    }

    const job = await getJobStatus(imageId);

    if (!job) {
        return response(404, { error: "Job not found" });
    }

    const { status, error_en, error_ua } = job;
    const result = status === "REJECTED" ? { status, error_en, error_ua } : { status };

    return response(200, result);
}
