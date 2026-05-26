import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.UPLOAD_JOBS_TABLE || "UploadJobs";

export async function getJobStatus(imageId) {
    const result = await docClient.send(new GetCommand({
        TableName: TABLE_NAME,
        Key: { imageId },
        ProjectionExpression: "#st, error_en, error_ua",
        ExpressionAttributeNames: { "#st": "status" },
    }));
    return result.Item ?? null;
}
