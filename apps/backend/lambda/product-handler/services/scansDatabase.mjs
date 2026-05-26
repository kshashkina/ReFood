import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const SCANS_TABLE = process.env.SCANS_TABLE || "Scans";

export const recordScan = async (userId, product) => {
    const params = {
        TableName: SCANS_TABLE,
        Item: {
            userId: userId,
            timestamp: new Date().toISOString(),
            barcode: product.barcode,
            productVersion: product.updated_at,
            productName: product.product_name,
            productBrand: product.brand,
            image: product.image_url
        }
    };
    return await docClient.send(new PutCommand(params));
};
