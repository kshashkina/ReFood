import { getMetrics, incrementScanned, incrementSorted, updateStreak, trackMapCheck, incrementAddedProducts, deleteMetrics } from './services/userMetricsDatabase.mjs';
import { calculateProgress, countUnlocked } from './helpers/progressCalculator.mjs';
import { ACHIEVEMENTS } from './helpers/achivementsConfig.mjs';

const getTimeContext = () => {
    const now = new Date();
    const hour = now.getUTCHours();
    const day = now.getUTCDay();
    const isWeekend = day === 0 || day === 6;
    return { hour, isWeekend };
};

export const handler = async (event) => {
    const { action, userId } = event;

    if (!userId) {
        console.warn('MetricsService: missing userId');
        return { success: false, error: 'Missing userId' };
    }

    try {
        switch (action) {

            case 'INCREMENT_SCANNED': {
                const { hour, isWeekend } = getTimeContext();
                await incrementScanned(userId, { hour, isWeekend });
                return { success: true };
            }

            case 'INCREMENT_SORTED': {
                await incrementSorted(userId);
                return { success: true };
            }

            case 'UPDATE_STREAK': {
                await updateStreak(userId);
                return { success: true };
            }

            case 'TRACK_MAP_CHECK': {
                const { hour, isWeekend } = getTimeContext();
                await trackMapCheck(userId, { hour, isWeekend });
                return { success: true };
            }

            case 'INCREMENT_PRODUCT': {
                await incrementAddedProducts(userId);
                return { success: true };
            }

            case 'GET_ACHIEVEMENTS': {
                const metrics = await getMetrics(userId);
                const achievements = calculateProgress(metrics);
                return {
                    success: true,
                    achievements,
                    totalUnlocked: countUnlocked(achievements),
                    total: ACHIEVEMENTS.length
                };
            }

            case 'DELETE_METRICS': {
                await deleteMetrics(userId);
                return { success: true };
            }

            default:
                console.warn(`MetricsService: unknown action "${action}"`);
                return { success: false, error: `Unknown action: ${action}` };
        }
    } catch (error) {
        console.error(`MetricsService error:`, error);
        return { success: false, error: error.message };
    }
};
