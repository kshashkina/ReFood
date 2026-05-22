import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand, DeleteCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const FAVORITES_TABLE = process.env.FAVORITES_TABLE || "ProductsFavorites";

export const getFavorite = async (userId, barcode) => {
    const result = await docClient.send(new GetCommand({
        TableName: FAVORITES_TABLE,
        Key: { userId, barcode }
    }));
    return result.Item || null;
};

export const addFavorite = async (userId, product) => {
    await docClient.send(new PutCommand({
        TableName: FAVORITES_TABLE,
        Item: {
            userId: userId,
            barcode: product.barcode,
            timestamp: new Date().toISOString(),
            productVersion: product.updated_at,
            productName: product.product_name,
            productBrand: product.brands,
            image: product.image_url
        }
    }));
};

export const removeFavorite = async (userId, barcode) => {
    await docClient.send(new DeleteCommand({
        TableName: FAVORITES_TABLE,
        Key: { userId, barcode }
    }));
};

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
