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

const actions = {
    increment_scanned: async ({ userId }) => {
        const { hour, isWeekend } = getTimeContext();
        await incrementScanned(userId, { hour, isWeekend });
        return { success: true };
    },

    increment_sorted: async ({ userId }) => {
        await incrementSorted(userId);
        return { success: true };
    },

    update_streak: async ({ userId }) => {
        await updateStreak(userId);
        return { success: true };
    },

    track_map_check: async ({ userId }) => {
        const { hour, isWeekend } = getTimeContext();
        await trackMapCheck(userId, { hour, isWeekend });
        return { success: true };
    },

    increment_product: async ({ userId }) => {
        await incrementAddedProducts(userId);
        return { success: true };
    },

    get_achievements: async ({ userId }) => {
        const metrics = await getMetrics(userId);
        const achievements = calculateProgress(metrics);
        return {
            success: true,
            achievements,
            totalUnlocked: countUnlocked(achievements),
            total: ACHIEVEMENTS.length
        };
    },

    get_counts: async ({ userId }) => {
        const metrics = await getMetrics(userId);
        return {
            success: true,
            scannedCount: metrics?.scannedCount ?? 0,
            sortedCount: metrics?.sortedCount ?? 0
        };
    },

    delete_metrics: async ({ userId }) => {
        await deleteMetrics(userId);
        return { success: true };
    }
};

export const handler = async (event) => {
    const { action, userId } = event;

    if (!userId) {
        console.warn('MetricsService: missing userId');
        return { success: false, error: 'Missing userId' };
    }

    if (!action || !actions[action]) {
        return {
            success: false,
            error: `Unknown action: "${action}". Available: ${Object.keys(actions).join(', ')}`
        };
    }

    try {
        return await actions[action](event);
    } catch (error) {
        console.error(`MetricsService error [${action}]:`, error);
        return { success: false, error: error.message };
    }
};

