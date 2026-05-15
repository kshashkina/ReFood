import { updateJobStatus } from "../services/uploadJobsDatabase.mjs";
import { checkPhoto } from "../services/aiService.mjs";

const BUCKET_NAME = process.env.S3_BUCKET_NAME;

export async function validateImage(event) {
    const results = [];

    for (const record of event.Records) {
        const s3Key = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));
        const filename = s3Key.split("/").pop();
        const imageId = filename.split(".").slice(0, -1).join(".");

        console.log(`S3 notification received: s3Key=${s3Key}, imageId=${imageId}`);
        try {
            const imageUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${s3Key}`;
            const aiResult = await checkPhoto(imageUrl);

            const isValid = aiResult?.isValid ?? false;
            const error_en = aiResult?.error_en || null;
            const error_ua = aiResult?.error_ua || null;
            const status = isValid ? "APPROVED" : "REJECTED";

            await updateJobStatus(imageId, status, error_en, error_ua);

            results.push({ imageId, status });
        } catch (error) {
            await updateJobStatus(imageId, "REJECTED", {
                error_en: "Validation error. Please try again.",
                error_ua: "Помилка валідації. Спробуйте ще раз.",
            });
            results.push({ imageId, status: "REJECTED", error: error.message });
        }
    }

    return { processed: results.length, results };
}
