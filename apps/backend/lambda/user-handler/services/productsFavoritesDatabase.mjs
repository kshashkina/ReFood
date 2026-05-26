import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

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
