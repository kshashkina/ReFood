import { cleanValue } from './cleanValue.mjs';
import { extractNutriments } from '../nutriments/extractNutriments.mjs';
import { parseToGrams } from '../nutriments/parseToGrams.mjs';

export function cleanProductData(data) {
    const quantityInGrams = parseToGrams(data.product_quantity || data.quantity);
    const servingInGrams = parseToGrams(data.serving_size || data.serving_quantity);

    return {
        product_name: cleanValue(data.product_name),
        brands: cleanValue(data.brands),
        ingredients_text: cleanValue(data.ingredients_text).toLowerCase() || null,
        ingredients_analysis_tags: cleanValue(data.ingredients_analysis_tags)?.toLowerCase() || null,
        categories_tags: cleanValue(data.categories_tags)?.toLowerCase() || null,
        allergens_tags: cleanValue(data.allergens_tags)?.toLowerCase() || null,
        nutriscore_grade: cleanValue(data.nutriscore_grade)?.toLowerCase() || null,
        ecoscore_grade: cleanValue(data.ecoscore_grade)?.toLowerCase() || null,
        nova_group: typeof data.nova_group === 'number' ? data.nova_group : null,
        nutriments: extractNutriments(data.nutriments || {}, servingInGrams, quantityInGrams),
        quantity: cleanValue(data.quantity),
        serving_size: cleanValue(data.serving_size),
        serving_quantity: cleanValue(data.serving_quantity),
        packaging: cleanPackaging(data.packaging),
        image_url: data.image_url
    };
}

function cleanPackaging(packaging) {
    if (!Array.isArray(packaging)) return [];

    return packaging.map(pkg => ({
        material: cleanValue(pkg.material),
        number_of_units: typeof pkg.number_of_units === 'number' ? pkg.number_of_units : 1,
        shape: cleanValue(pkg.shape),
        recycling: cleanValue(pkg.recycling)
    })).filter(pkg => pkg.material || pkg.shape);
}
