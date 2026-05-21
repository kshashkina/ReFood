import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, QueryCommand, PutCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const USERS_TABLE = process.env.TABLE_NAME || "Users";
const DEVICE_INDEX = process.env.DEVICE_INDEX || "deviceId-index";
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

export const findUserByDevice = async (deviceId) => {
    const params = {
        TableName: USERS_TABLE,
        IndexName: DEVICE_INDEX,
        KeyConditionExpression: "deviceId = :d",
        ExpressionAttributeValues: { ":d": deviceId }
    };

    const { Items } = await docClient.send(new QueryCommand(params));
    return Items && Items.length > 0 ? Items[0] : null;
};

export const createUser = async (user) => {
    const params = {
        TableName: USERS_TABLE,
        Item: user,
        ConditionExpression: "attribute_not_exists(userId)"
    };
    return await docClient.send(new PutCommand(params));
};

export const updateIdentityId = async (userId, newIdentityId) => {
    const params = {
        TableName: USERS_TABLE,
        Key: { userId },
        UpdateExpression: "set identityId = :i",
        ExpressionAttributeValues: {
            ":i": newIdentityId
        }
    };
    return await docClient.send(new UpdateCommand(params));
};

export const getUserProfile = async (userId) => {
    const params = {
        TableName: USERS_TABLE,
        Key: { userId }
    };
    const result = await docClient.send(new GetCommand(params));
    return result.Item;
};

