import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

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

export const getUserScansPaginated = async (userId, limit = 20, lastKey = undefined) => {
    const result = await docClient.send(new QueryCommand({
        TableName: SCANS_TABLE,
        KeyConditionExpression: "userId = :uid",
        ExpressionAttributeValues: { ":uid": userId },
        ScanIndexForward: false,
        Limit: limit,
        ...(lastKey && { ExclusiveStartKey: lastKey })
    }));

    return {
        items: result.Items || [],
        lastKey: result.LastEvaluatedKey || null
    };
};

export const deleteAllUserScans = async (userId) => {
    let lastKey;
    const deletePromises = [];

    do {
        const result = await docClient.send(new QueryCommand({
            TableName: SCANS_TABLE,
            KeyConditionExpression: "userId = :uid",
            ExpressionAttributeValues: { ":uid": userId },
            ExclusiveStartKey: lastKey,
            ProjectionExpression: "userId, #ts",
            ExpressionAttributeNames: { "#ts": "timestamp" }
        }));

        for (const item of result.Items || []) {
            deletePromises.push(
                docClient.send(new DeleteCommand({
                    TableName: SCANS_TABLE,
                    Key: { userId: item.userId, timestamp: item.timestamp }
                }))
            );
        }

        lastKey = result.LastEvaluatedKey;
    } while (lastKey);

    await Promise.all(deletePromises);
};
