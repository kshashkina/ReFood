import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { response } from "../helpers/response.mjs";
import { randomUUID } from "crypto";

const s3Client = new S3Client({ region: process.env.AWS_REGION || "eu-north-1" });
const BUCKET_NAME = process.env.S3_BUCKET_NAME;
const URL_EXPIRY_SECONDS = 300;

const ALLOWED_CONTENT_TYPE = "image/jpeg";
const ALLOWED_FILE_EXTENSION = "jpg";

export async function getPresignedUrl() {
    if (!BUCKET_NAME) {
        console.error("S3_BUCKET_NAME env variable is not set");
        return response(500, {
            error: "Storage configuration error"
        });
    }

    const imageId = randomUUID();
    const s3Key = `temp/${imageId}.${ALLOWED_FILE_EXTENSION}`;

    const command = new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: s3Key,
        ContentType: ALLOWED_CONTENT_TYPE
    });

    const presignedUrl = await getSignedUrl(s3Client, command, {
        expiresIn: URL_EXPIRY_SECONDS,
    });

    const imageUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${s3Key}`;

    return response(200, {
        uploadUrl: presignedUrl,
        imageId,
        s3Key,
        imageUrl,
        expiresIn: URL_EXPIRY_SECONDS,
    });
}
