import { response } from '../helpers/response.mjs';
import { findUserByCognitoSub, deleteUser } from '../services/usersDatabase.mjs';
import { deleteAllUserScans } from '../services/scansDatabase.mjs';

export const deleteUserData = async (event) => {
    const claims = event.requestContext?.authorizer?.claims || event.requestContext?.authorizer?.jwt?.claims;
    const cognitoSub = claims?.sub;

    if (!cognitoSub) {
        return response(401, { error: "Authorization required" });
    }

    try {
        const user = await findUserByCognitoSub(cognitoSub);

        if (!user) {
            return response(404, { error: "User not found" });
        }

        await deleteAllUserScans(user.userId);
        await deleteUser(user.userId);

        console.log(`User data deleted: ${user.userId}`);
        return response(200, { message: "All user data deleted" });
    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Failed to delete account"
        });
    }
};
