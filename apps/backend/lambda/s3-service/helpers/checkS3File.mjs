import { HeadObjectCommand } from "@aws-sdk/client-s3";

export async function fileExistsInS3(s3Client, bucketName, key) {
    try {
        await s3Client.send(new HeadObjectCommand({
            Bucket: bucketName,
            Key: key
        }));
        return true;
    } catch (error) {
        if (error.name === "NotFound" || error.$metadata?.httpStatusCode === 404) {
            return false;
        }
        throw error;
    }
}
