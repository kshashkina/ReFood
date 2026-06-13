import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const FAVORITES_TABLE = process.env.FAVORITES_TABLE || "ProductsFavorites";

export const getUserFavorites = async (userId, limit = 20, lastKey = undefined) => {
    const result = await docClient.send(new QueryCommand({
        TableName: FAVORITES_TABLE,
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

export const deleteAllUserFavorites = async (userId) => {
    let lastKey;
    const deletePromises = [];

    do {
        const result = await docClient.send(new QueryCommand({
            TableName: FAVORITES_TABLE,
            KeyConditionExpression: "userId = :uid",
            ExpressionAttributeValues: { ":uid": userId },
            ExclusiveStartKey: lastKey,
            ProjectionExpression: "userId, barcode"
        }));

        for (const item of result.Items || []) {
            deletePromises.push(
                docClient.send(new DeleteCommand({
                    TableName: FAVORITES_TABLE,
                    Key: { userId: item.userId, barcode: item.barcode }
                }))
            );
        }

        lastKey = result.LastEvaluatedKey;
    } while (lastKey);

    await Promise.all(deletePromises);
};
