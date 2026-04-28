export const validateRegisterRequest = (body) => {
    const { identityId, deviceId } = body;
    const errors = [];

    if (!identityId || typeof identityId !== 'string') {
        errors.push("Invalid or missing identityId");
    }

    if (!deviceId || typeof deviceId !== 'string') {
        errors.push("Invalid or missing deviceId");
    }

    return {
        valid: errors.length === 0,
        errors
    };
};
