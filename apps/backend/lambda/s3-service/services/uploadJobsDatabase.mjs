import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.UPLOAD_JOBS_TABLE || "UploadJobs";
const ttlIn24h = () => Math.floor(Date.now() / 1000) + 60 * 60 * 24;

export async function createPendingJob(imageId, s3Key) {
    await docClient.send(new PutCommand({
        TableName: TABLE_NAME,
        Item: {
            imageId,
            s3Key,
            status: "PENDING",
            createdAt: new Date().toISOString(),
            ttl: ttlIn24h(),
        },
        ConditionExpression: "attribute_not_exists(imageId)"
    }));
}

export async function updateJobStatus(imageId, status, error_en, error_ua) {
    await docClient.send(new UpdateCommand({
        TableName: TABLE_NAME,
        Key: { imageId },
        UpdateExpression:
            "SET #st = :status, error_en = :error_en, error_ua = :error_ua, updatedAt = :updatedAt",
        ExpressionAttributeNames: { "#st": "status" },
        ExpressionAttributeValues: {
            ":status": status,
            ":error_en": error_en,
            ":error_ua": error_ua,
            ":updatedAt": new Date().toISOString(),
        }
    }));
}

export async function getJobStatus(imageId) {
    const result = await docClient.send(new GetCommand({
        TableName: TABLE_NAME,
        Key: { imageId },
    }));
    return result.Item ?? null;
}
