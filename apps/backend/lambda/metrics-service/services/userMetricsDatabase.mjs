import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const USER_METRICS_TABLE = process.env.METRICS_TABLE || "UserMetrics";

export const getMetrics = async (userId) => {
    const result = await docClient.send(new GetCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId }
    }));
    return result.Item || null;
};

export const incrementScanned = async (userId, { hour, isWeekend }) => {
    const now = new Date().toISOString();

    let updateExpr = "ADD scannedCount :inc SET lastUpdated = :now";
    const exprAttrValues = { ":inc": 1, ":now": now };

    if (hour < 9) {
        updateExpr += ", earlyBirdUnlocked = :true";
        updateExpr += ", earlyBirdUnlockedAt = if_not_exists(earlyBirdUnlockedAt, :now)";
        exprAttrValues[":true"] = true;
    }

    if (isWeekend) {
        updateExpr += ", weekendHasScanned = :true";
        exprAttrValues[":true"] = true;
    }

    await docClient.send(new UpdateCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId },
        UpdateExpression: updateExpr,
        ExpressionAttributeValues: exprAttrValues
    }));

    if (isWeekend) {
        await checkAndSetEcoWeekend(userId, now);
    }
};

export const trackMapCheck = async (userId, { hour, isWeekend }) => {
    const now = new Date().toISOString();
    let updateExpr = "SET lastUpdated = :now";
    const exprAttrValues = { ":now": now };

    if (hour >= 20 || isWeekend) {
        updateExpr += ", ninjaSortingUnlocked = :true";
        updateExpr += ", ninjaSortingUnlockedAt = if_not_exists(ninjaSortingUnlockedAt, :now)";
        exprAttrValues[":true"] = true;
    }

    if (isWeekend) {
        updateExpr += ", weekendHasMapped = :true";
        if (!exprAttrValues[":true"]) exprAttrValues[":true"] = true;
    }

    await docClient.send(new UpdateCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId },
        UpdateExpression: updateExpr,
        ExpressionAttributeValues: exprAttrValues
    }));

    if (isWeekend) {
        await checkAndSetEcoWeekend(userId, now);
    }
};

const checkAndSetEcoWeekend = async (userId, now) => {
    const metrics = await getMetrics(userId);
    if (!metrics) return;

    if (metrics.weekendHasScanned && metrics.weekendHasMapped && !metrics.ecoWeekendUnlocked) {
        await docClient.send(new UpdateCommand({
            TableName: USER_METRICS_TABLE,
            Key: { userId },
            UpdateExpression: "SET ecoWeekendUnlocked = :true, ecoWeekendUnlockedAt = :now",
            ExpressionAttributeValues: { ":true": true, ":now": now }
        }));
    }
};

export const incrementSorted = async (userId) => {
    await docClient.send(new UpdateCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId },
        UpdateExpression: "ADD sortedCount :inc SET lastUpdated = :now",
        ExpressionAttributeValues: { ":inc": 1, ":now": new Date().toISOString() }
    }));
};

export const updateStreak = async (userId) => {
    const metrics = await getMetrics(userId);
    const now = new Date();
    const nowISO = now.toISOString();

    if (!metrics) {
        await docClient.send(new UpdateCommand({
            TableName: USER_METRICS_TABLE,
            Key: { userId },
            UpdateExpression: "SET streakDays = :one, lastOpenedDate = :now, lastUpdated = :now",
            ExpressionAttributeValues: { ":one": 1, ":now": nowISO }
        }));
        return;
    }

    const lastOpened = metrics.lastOpenedDate ? new Date(metrics.lastOpenedDate) : null;

    if (lastOpened) {
        const today = now.toISOString().slice(0, 10);
        const last = lastOpened.toISOString().slice(0, 10);

        if (today === last) {
            return;
        }

        const openedOnNextDay = Math.round((now - lastOpened) / (1000 * 60 * 60 * 24));

        if (openedOnNextDay === 1) {
            await docClient.send(new UpdateCommand({
                TableName: USER_METRICS_TABLE,
                Key: { userId },
                UpdateExpression: "ADD streakDays :inc SET lastOpenedDate = :now, lastUpdated = :now",
                ExpressionAttributeValues: { ":inc": 1, ":now": nowISO }
            }));
        } else {
            await docClient.send(new UpdateCommand({
                TableName: USER_METRICS_TABLE,
                Key: { userId },
                UpdateExpression: "SET streakDays = :one, lastOpenedDate = :now, lastUpdated = :now",
                ExpressionAttributeValues: { ":one": 1, ":now": nowISO }
            }));
        }
    } else {
        await docClient.send(new UpdateCommand({
            TableName: USER_METRICS_TABLE,
            Key: { userId },
            UpdateExpression: "SET streakDays = :one, lastOpenedDate = :now, lastUpdated = :now",
            ExpressionAttributeValues: { ":one": 1, ":now": nowISO }
        }));
    }
};

export const incrementAddedProducts = async (userId) => {
    await docClient.send(new UpdateCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId },
        UpdateExpression: "ADD addedProductsCount :inc SET lastUpdated = :now",
        ExpressionAttributeValues: { ":inc": 1, ":now": new Date().toISOString() }
    }));
};

export const deleteMetrics = async (userId) => {
    await docClient.send(new DeleteCommand({
        TableName: USER_METRICS_TABLE,
        Key: { userId }
    }));
};
