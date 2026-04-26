import { S3Client, HeadObjectCommand } from "@aws-sdk/client-s3";
import { response } from "../helpers/response.mjs";
import { checkPhoto } from "../services/aiService.mjs";

const s3Client = new S3Client({ region: process.env.AWS_REGION || "eu-north-1" });
const BUCKET_NAME = process.env.S3_BUCKET_NAME;

export async function validateImage(event) {
    let body;
    try {
        body = JSON.parse(event.body || "{}");
    } catch {
        return response(400, { error: "Invalid JSON body" });
    }

    const { s3Key, imageId } = body;

    if (!s3Key || !imageId) {
        return response(400, { error: "Missing required fields: s3Key, imageId" });
    }

    if (!s3Key.startsWith("temp/")) {
        return response(400, { error: "Invalid s3Key: must be in temp/ prefix" });
    }

    try {
        await s3Client.send(new HeadObjectCommand({
            Bucket: BUCKET_NAME,
            Key: s3Key,
        }));
    } catch (error) {
        if (error.name === "NotFound" || error.$metadata?.httpStatusCode === 404) {
            return response(404, {
                error: "Image not found in S3. Please upload the file first.",
            });
        }
        throw error;
    }

    const imageUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${s3Key}`;

    console.log(`Validating image: ${imageUrl}`);

    const aiResult = await checkPhoto(imageUrl);

    const isValid = aiResult?.isValid ?? false;
    const error_en = aiResult?.error_en || null;
    const error_ua = aiResult?.error_ua || null;

    return response(200, {
        imageId,
        s3Key,
        imageUrl,
        isValid,
        error_en,
        error_ua
    });
}
