import { getJobStatus } from "../services/uploadJobsDatabase.mjs";

export async function requireApprovedJob(imageId) {
    const job = await getJobStatus(imageId);

    if (!job) {
        return { ok: false, code: "JOB_NOT_FOUND", message: `No upload job found for imageId: ${imageId}` };
    }
    if (job.status !== "APPROVED") {
        return { ok: false, code: "NOT_APPROVED", message: `Image not approved. Current status: ${job.status}` };
    }

    return { ok: true, job };
}
