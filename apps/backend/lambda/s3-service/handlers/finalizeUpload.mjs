import { S3Client, CopyObjectCommand, DeleteObjectCommand, HeadObjectCommand } from "@aws-sdk/client-s3";
import { response } from "../helpers/response.mjs";

const s3Client = new S3Client({ region: process.env.AWS_REGION || "eu-north-1" });
const BUCKET_NAME = process.env.S3_BUCKET_NAME;

export async function finalizeUpload(event) {
    let body;
    try {
        body = JSON.parse(event.body || "{}");
    } catch {
        return response(400, { error: "Invalid JSON body" });
    }

    const { s3Key, imageId, barcode } = body;

    if (!s3Key || !imageId || !barcode) {
        return response(400, { error: "Missing required fields: s3Key, imageId, barcode" });
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
                error: "Temp image not found. It may have already been finalized or expired.",
            });
        }
        throw error;
    }

    const fileExtension = s3Key.split(".").pop();
    const publicKey = `public/products/${barcode}/${imageId}.${fileExtension}`;

    await s3Client.send(new CopyObjectCommand({
        Bucket: BUCKET_NAME,
        CopySource: `${BUCKET_NAME}/${s3Key}`,
        Key: publicKey,
    }));

    console.log(`Moved ${s3Key} → ${publicKey}`);

    await s3Client.send(new DeleteObjectCommand({
        Bucket: BUCKET_NAME,
        Key: s3Key,
    }));

    const publicUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${publicKey}`;

    return response(200, {
        imageId,
        publicKey,
        publicUrl
    });
}
