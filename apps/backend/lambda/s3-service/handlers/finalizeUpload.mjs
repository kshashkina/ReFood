import { S3Client, CopyObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { requireApprovedJob } from "../helpers/checkApprovedStatus.mjs";
import { fileExistsInS3 } from "../helpers/checkS3File.mjs";

const s3Client = new S3Client({ region: process.env.AWS_REGION || "eu-north-1" });
const BUCKET_NAME = process.env.S3_BUCKET_NAME;

export async function finalizeUpload(event) {
    const { s3Key, imageId, barcode } = event;

    if (!s3Key || !imageId || !barcode) {
        throw new Error("Missing required fields: s3Key, imageId, barcode");
    }

    if (!s3Key.startsWith("temp/")) {
        throw new Error("Invalid s3Key: must be in temp/ prefix");
    }

    const check = await requireApprovedJob(imageId);
    if (!check.ok) return { success: false, code: check.code, message: check.message };

    const fileExtension = s3Key.split(".").pop();
    const publicKey = `public/products/${barcode}/${imageId}.${fileExtension}`;
    const publicUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${publicKey}`;

    const tempExists = await fileExistsInS3(s3Client, BUCKET_NAME, s3Key);

    if (!tempExists) {
        const publicExists = await fileExistsInS3(s3Client, BUCKET_NAME, publicKey);

        if (publicExists) {
            console.log(`Already finalized: ${publicKey}`);
            return { success: true, imageId, publicKey, publicUrl, alreadyFinalized: true };
        }

        return { success: false, code: "FILE_NOT_FOUND", message: "Image not found in temp or public. It may have expired." };
    }

    await s3Client.send(new CopyObjectCommand({
        Bucket: BUCKET_NAME,
        CopySource: `${BUCKET_NAME}/${s3Key}`,
        Key: publicKey,
    }));

    await s3Client.send(new DeleteObjectCommand({
        Bucket: BUCKET_NAME,
        Key: s3Key,
    }));

    return { success: true, imageId, publicKey, publicUrl };
}
