export function parseToGrams(weight) {
    if (typeof weight === 'number') return weight;
    if (!weight || typeof weight !== 'string') return null;

    const cleanWeight = weight.toLowerCase().replace(/\s+/g, '');
    const numericValue = parseFloat(cleanWeight);
    if (isNaN(numericValue)) return 0;

    if (cleanWeight.includes('kg') || cleanWeight.includes('кг')) {
        return numericValue * 1000;
    }
    
    if (cleanWeight.includes('mg') || cleanWeight.includes('мг')) {
        return numericValue / 1000;
    }

    if (cleanWeight.includes('l') && !cleanWeight.includes('ml')) {
        return numericValue * 1000;
    }

    return numericValue; 
}
