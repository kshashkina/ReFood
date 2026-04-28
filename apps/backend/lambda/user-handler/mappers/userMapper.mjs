import { randomUUID } from 'crypto';

export const toUserDBModel = (deviceId, identityId) => {
    return {
        userId: randomUUID(),
        deviceId: deviceId,
        identityId: identityId,
        isPremium: false,
        scansCount: 0,
        createdAt: new Date().toISOString()
    };
};
