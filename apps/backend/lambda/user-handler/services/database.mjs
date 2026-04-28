import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand, PutCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const USERS_TABLE = process.env.TABLE_NAME || "Users";
const DEVICE_INDEX = process.env.DEVICE_INDEX || "deviceId-index";

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
        Item: user
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
