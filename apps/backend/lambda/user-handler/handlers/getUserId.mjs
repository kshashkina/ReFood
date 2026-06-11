import { response } from '../helpers/response.mjs';
import { findUserByDevice, findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';

export const getUserId = async (event) => {
    const { deviceId } = event.queryStringParameters || {};

    if (!deviceId) {
        return response(400, { error: 'Missing required query parameter: deviceId' });
    }

    const identity = getRequestIdentity(event);
    if (!identity) {
        return response(401, { error: 'Unauthorized' });
    }

    try {
        const [userByDevice, userIdByAuth] = await Promise.all([
            findUserByDevice(deviceId),
            findUserIdByAnyMethod(identity)
        ]);

        if (!userByDevice || !userIdByAuth) {
            return response(404, { error: 'User not found' });
        }

        if (userByDevice.userId !== userIdByAuth) {
            return response(403, { error: 'Identity mismatch' });
        }

        return response(200, { userId: userByDevice.userId });
    } catch (error) {
        console.error('Error fetching userId:', error);
        return response(500, { error: 'Failed to retrieve user ID' });
    }
};
