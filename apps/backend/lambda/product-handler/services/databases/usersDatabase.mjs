import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const USERS_TABLE = process.env.USERS_TABLE || "Users";
const JWT_NAME = process.env.JWT_NAME || "cognitoSub";
const JWT_INDEX = process.env.JWT_INDEX || "cognitoSub-index";
const IDENTITY_INDEX = process.env.IDENTITY_INDEX || "identityId-index";
const IDENTITY_NAME = process.env.IDENTITY_NAME || "identityId";

export const findUserIdByAnyMethod = async (identity) => {
    if (!identity) return null;

    const indexName = identity.type === 'jwt' ? JWT_INDEX : IDENTITY_INDEX;
    const keyName = identity.type === 'jwt' ? JWT_NAME : IDENTITY_NAME;

    const params = {
        TableName: USERS_TABLE,
        IndexName: indexName,
        KeyConditionExpression: `${keyName} = :val`,
        ExpressionAttributeValues: { ":val": identity.id }
    };

    const result = await docClient.send(new QueryCommand(params));
    return result.Items?.[0]?.userId || null;
};

export const incrementUserScanCount = async (userId) => {
    const params = {
        TableName: USERS_TABLE,
        Key: { userId },
        UpdateExpression: "SET scansCount = if_not_exists(scansCount, :zero) + :inc",
        ExpressionAttributeValues: {
            ":inc": 1,
            ":zero": 0
        }
    };
    return await docClient.send(new UpdateCommand(params));
};