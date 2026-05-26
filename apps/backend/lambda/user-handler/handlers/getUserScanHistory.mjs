import { response } from '../helpers/response.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';
import { findUserIdByAnyMethod } from '../services/usersDatabase.mjs';
import { getUserScansPaginated } from '../services/scansDatabase.mjs';
import { toScanListResponse } from '../mappers/scanMapper.mjs';

export const getUserScanHistory = async (event) => {
    const identity = getRequestIdentity(event);
    const userId = await findUserIdByAnyMethod(identity);

    if (!userId) {
        return response(401, { error: "User not recognized" });
    }

    const query = event.queryStringParameters || {};
    const limit = Math.min(parseInt(query.limit) || 20, 100);

    let lastKey;
    if (query.nextToken) {
        try {
            lastKey = JSON.parse(Buffer.from(query.nextToken, 'base64').toString('utf8'));
        } catch {
            return response(400, { error: "Invalid nextToken" });
        }
    }

    const { items, lastKey: newLastKey } = await getUserScansPaginated(userId, limit, lastKey);
    const nextToken = newLastKey ? Buffer.from(JSON.stringify(newLastKey)).toString('base64') : null;

    return response(200, {
        scans: toScanListResponse(items),
        ...(nextToken && { nextToken })
    });
};
