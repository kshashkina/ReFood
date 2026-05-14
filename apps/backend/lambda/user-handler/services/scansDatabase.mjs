import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const SCANS_TABLE = process.env.SCANS_TABLE || "Scans";

export const getUserScans = async (userId, limit = 20) => {
    const params = {
        TableName: SCANS_TABLE,
        KeyConditionExpression: "userId = :uid",
        ExpressionAttributeValues: {
            ":uid": userId
        },
        ScanIndexForward: false,
        Limit: limit
    };

    const result = await docClient.send(new QueryCommand(params));
    return result.Items || [];
};
