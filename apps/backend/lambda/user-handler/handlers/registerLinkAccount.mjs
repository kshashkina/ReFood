import { response } from '../helpers/response.mjs';
import { findUserByCognitoSub, findUserByDevice, linkUserToApple, updateUserDevice, deleteUser } from '../services/usersDatabase.mjs';

export const registerLinkAccount = async (event) => {
    const claims = event.requestContext?.authorizer?.claims || event.requestContext?.authorizer?.jwt?.claims;
    const cognitoSub = claims?.sub;

    if (!cognitoSub) {
        return response(401, { error: "Missing or invalid authorization token" });
    }

    let body;
    try {
        body = JSON.parse(event.body || "{}");
    } catch {
        return response(400, { error: "Invalid JSON body" });
    }

    const { deviceId } = body;
    if (!deviceId || typeof deviceId !== 'string') {
        return response(400, { error: "Missing or invalid deviceId" });
    }

    const email = claims.email || null;
    const givenName = claims.given_name || null;

    try {
        const existingAppleUser = await findUserByCognitoSub(cognitoSub);

        if (existingAppleUser) {
            const anonymousUser = await findUserByDevice(deviceId);

            await updateUserDevice(existingAppleUser.userId, deviceId);

            if (anonymousUser && anonymousUser.userId !== existingAppleUser.userId) {
                await deleteUser(anonymousUser.userId);
            }

            return response(200, { message: "Welcome back" });
        }

        const anonymousUser = await findUserByDevice(deviceId);

        if (anonymousUser) {
            await linkUserToApple(anonymousUser.userId, { cognitoSub, email, givenName });

            console.log(`Anonymous user linked to Apple: ${anonymousUser.userId}`);

            return response(200, { message: "Account linked" });
        }

        return response(409, { error: "No user session found for this device. Call /users/register first." });
    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Failed to link account"
        });
    }
};
