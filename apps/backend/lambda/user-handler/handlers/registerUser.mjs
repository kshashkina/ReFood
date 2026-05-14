import { response } from '../helpers/response.mjs';
import { findUserByDevice, createUser, updateIdentityId } from '../services/usersDatabase.mjs';
import { validateRegisterRequest } from '../helpers/validation/userValidator.mjs';
import { toUserDBModel } from '../mappers/userMapper.mjs';

export const registerUser = async (event) => {
    let body;
    try {
        body = JSON.parse(event.body || "{}");
    } catch {
        return response(400, { error: "Invalid JSON body" });
    }

    const validation = validateRegisterRequest(body);
    if (!validation.valid) {
        return response(400, {
            error: "Validation failed",
            details: validation.errors
        });
    }

    try {
        const existingUser = await findUserByDevice(body.deviceId);

        if (existingUser) {
            if (existingUser.identityId !== body.identityId) {
                await updateIdentityId(existingUser.userId, body.identityId);
            }

            return response(200, {
                userId: existingUser.userId,
                message: "User recognized"
            });
        }

        const newUser = toUserDBModel(body.deviceId, body.identityId);
        await createUser(newUser);

        return response(201, {
            userId: newUser.userId,
            message: "New user created"
        });

    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Failed to register user"
        });
    }
};
