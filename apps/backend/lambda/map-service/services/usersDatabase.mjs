import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

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
