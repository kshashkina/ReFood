import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const NEWS_TABLE = process.env.NEWS_TABLE || "News";
const NEWS_INDEX_NAME = process.env.NEWS_INDEX_NAME || "NewsByDateIndex";

export const checkNewsExists = async (newsId) => {
    const res = await docClient.send(new GetCommand({
        TableName: NEWS_TABLE,
        Key: { news_id: newsId }
    }));
    return !!res.Item;
};

export const saveNewsToDb = async (article) => {
    return await docClient.send(new PutCommand({
        TableName: NEWS_TABLE,
        Item: {
            news_id: article.id,
            news_type: "RESEARCH",
            date: article.date,
            resource: article.resource,
            created_at: new Date().toISOString(),
            link: `https://pubmed.ncbi.nlm.nih.gov/${article.id}/`,
            ...article.ai_processed
        }
    }));
};

export const getLatestNewsFromDb = async (limit = 10) => {
    const params = {
        TableName: NEWS_TABLE,
        IndexName: NEWS_INDEX_NAME,
        KeyConditionExpression: "news_type = :t",
        ExpressionAttributeValues: { ":t": "RESEARCH" },
        ScanIndexForward: false,
        Limit: limit
    };
    const res = await docClient.send(new QueryCommand(params));
    return res.Items || [];
};
