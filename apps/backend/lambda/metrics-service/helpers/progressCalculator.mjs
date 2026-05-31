import { ACHIEVEMENTS } from './achivementsConfig.mjs';

export const calculateProgress = (metrics) => {
    if (!metrics) {
        return ACHIEVEMENTS.map(a => ({
            id: a.id,
            title_en: a.title_en,
            title_ua: a.title_ua,
            description_en: a.description_en,
            description_ua: a.description_ua,
            goal: a.goal,
            current: 0,
            isUnlocked: false,
            unlockedAt: null
        }));
    }

    return ACHIEVEMENTS.map(a => {
        const rawValue = metrics[a.type];

        const isBoolean = typeof rawValue === 'boolean';
        const current = isBoolean ? (rawValue ? 1 : 0) : Math.min(rawValue || 0, a.goal);
        const isUnlocked = current >= a.goal;

        const unlockedAtKey = `${a.type}UnlockedAt`;
        const unlockedAt = isUnlocked ? (metrics[unlockedAtKey] || null) : null;

        return {
            id: a.id,
            title_en: a.title_en,
            title_ua: a.title_ua,
            description_en: a.description_en,
            description_ua: a.description_ua,
            goal: a.goal,
            current,
            isUnlocked,
            unlockedAt
        };
    });
};

export const countUnlocked = (progressList) => progressList.filter(a => a.isUnlocked).length;
