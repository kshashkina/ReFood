import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

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
