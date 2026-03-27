import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const PRODUCTS_TABLE = process.env.PRODUCTS_TABLE || "Products_V2";

export async function getLatestProductFromDB(barcode) {
    const params = {
        TableName: PRODUCTS_TABLE,
        KeyConditionExpression: "barcode = :b",
        ExpressionAttributeValues: {
            ":b": barcode
        },
        ScanIndexForward: false, 
        Limit: 1
    };

    const result = await docClient.send(new QueryCommand(params));
    
    return result.Items && result.Items.length > 0 ? result.Items[0] : null;
}

export async function saveProductToDB(product) {
    await docClient.send(new PutCommand({
        TableName: PRODUCTS_TABLE,
        Item: product
    }));
    console.log(`Saved product to DB: ${product.barcode}`);
}
