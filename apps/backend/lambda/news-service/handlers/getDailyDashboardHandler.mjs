import { getDailyTip } from '../services/dailyTipsDatabase.mjs';
import { getLatestNewsFromDb } from '../services/newsDatabase.mjs';
import { response } from '../helpers/response.mjs';

export const getSummaryHandler = async (event) => {
    const requestTimestamp = event.requestContext?.timeEpoch ? new Date(event.requestContext.timeEpoch) : new Date();
    const tipDate = `${String(requestTimestamp.getUTCDate()).padStart(2, '0')}.${String(requestTimestamp.getUTCMonth() + 1).padStart(2, '0')}`;

    const [tipResult, newsResult] = await Promise.all([
        getDailyTip(tipDate),
        getLatestNewsFromDb(10)
    ]);

    return response(200, {
        date_utc: requestTimestamp.toISOString().split('T')[0],
        tip: tipResult.Item || null,
        news: newsResult || []
    });
};
