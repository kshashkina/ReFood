import { cleanValue } from './cleanValue.mjs';
import { extractNutriments } from './nutriments.mjs';

export function cleanProductData(data) {
    return {
        product_name: cleanValue(data.product_name),
        brands: cleanValue(data.brands),
        categories_tags_en: Array.isArray(data.categories_tags) ? data.categories_tags : [],
        categories_tags_ua: Array.isArray(data.categories_tags) ? data.categories_tags : [],
        ingredients_text_ua: cleanValue(data.ingredients_text_ua),
        ingredients_text_en: cleanValue(data.ingredients_text_en),
        allergens_en: Array.isArray(data.allergens_tags) ? data.allergens_tags : [],
        allergens_ua: Array.isArray(data.allergens_tags) ? data.allergens_tags : [],
        nutriscore_grade: cleanValue(data.nutriscore_grade)?.toLowerCase() || null,
        nutriscore_score: typeof data.nutriscore_score === 'number' ? data.nutriscore_score : null,
        ecoscore_grade: cleanValue(data.ecoscore_grade)?.toLowerCase() || null,
        ecoscore_score: typeof data.ecoscore_score === 'number' ? data.ecoscore_score : null,
        nova_group: typeof data.nova_group === 'number' ? data.nova_group : null,
        nutriments: data.nutriments ? extractNutriments(data.nutriments) : extractNutriments({}),
        quantity: cleanValue(data.quantity),
        serving_size: cleanValue(data.serving_size),
        serving_quantity: typeof data.serving_quantity === 'number' ? data.serving_quantity : null,
        packaging: cleanPackaging(data.packaging),
        image_url: cleanValue(data.image_url),
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
