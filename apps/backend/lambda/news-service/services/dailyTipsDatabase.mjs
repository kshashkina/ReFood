import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const DAILY_TIPS_TABLE = process.env.DAILY_TIPS_TABLE || "DailyTips";

export const getDailyTip = async (tipDate) => {
    return await docClient.send(new GetCommand({
        TableName: DAILY_TIPS_TABLE,
        Key: { tip_date: tipDate }
    }));
};
