export function calculateTotalNutrients(nutrientPer100g, totalWeightGrams) {
    if (!nutrientPer100g || !totalWeightGrams) return null;

    const total = (nutrientPer100g / 100) * totalWeightGrams;
    return Number(total.toFixed(2));
}

