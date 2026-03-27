export function cleanValue(value) {
    if (value === null || value === undefined) {
        return null;
    }

    if (Array.isArray(value)) {
        return value
            .map(item => cleanValue(item))
            .filter(item => item !== null);
    }

    if (typeof value !== 'string') {
        return value;
    }

    const normalized = value
        .trim()
        .replace(/^[a-z]{2,3}:(?!\/\/)/i, '')
        .trim();

    const check = ["", "undefined", "unknown", "null", "not-applicable"];
    if (check.includes(normalized.toLowerCase())) {
        return null;
    }

    return normalized;
}
