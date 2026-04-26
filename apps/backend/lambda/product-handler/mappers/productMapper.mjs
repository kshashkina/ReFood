import { cleanValue } from '../helpers/formatters/cleanValue.mjs';
import { extractNutriments } from '../helpers/nutriments/extractNutriments.mjs';
import { parseToGrams } from '../helpers/nutriments/parseToGrams.mjs';

export function offProductToProduct(barcode, offProduct) {
    const now = Date.now();
    
    const quantityInGrams = parseToGrams(offProduct.product_quantity || offProduct.quantity);
    const servingInGrams = parseToGrams(offProduct.serving_size || offProduct.serving_quantity);

    return {
        barcode,
        product_name: cleanValue(offProduct.product_name || offProduct.generic_name),
        product_name_en: cleanValue(offProduct.product_name_en || offProduct.generic_name_en),
        brands: cleanValue(offProduct.brands),
        categories_tags: cleanValue(offProduct.categories_tags),
        ingredients_text: cleanValue(offProduct.ingredients_text),
        ingredients_text_en: cleanValue(offProduct.ingredients_text_en),
        ingredients_analysis_tags: cleanValue(offProduct.ingredients_analysis_tags),
        allergens_tags: cleanValue(offProduct.allergens_tags),
        traces_tags: cleanValue(offProduct.traces_tags),
        nutriscore_grade: cleanValue(offProduct.nutriscore_grade),
        nutriscore_score: cleanValue(offProduct.nutriscore_score),
        ecoscore_grade: cleanValue(offProduct.ecoscore_grade),
        ecoscore_score: cleanValue(offProduct.ecoscore_score),
        nova_group: cleanValue(offProduct.nova_group),
        nutriments: extractNutriments(offProduct.nutriments || {}, servingInGrams, quantityInGrams),
        quantity: cleanValue(offProduct.quantity),
        serving_size: cleanValue(offProduct.serving_size),
        serving_quantity: cleanValue(offProduct.serving_quantity),
        packaging: offProduct.ecoscore_data?.adjustments?.packaging?.packagings?.map(pkg => ({
            material: cleanValue(pkg.material),
            number_of_units: pkg.number_of_units ?? 1,
            shape: cleanValue(pkg.shape),
            recycling: cleanValue(pkg.recycling)
        })) || [],
        image_url: cleanValue(offProduct.image_url),
        source: "openfoodfacts",
        off_id: cleanValue(offProduct._id),
        updated_at: now
    };
}


export function toProductResponse(product) {
    return {
        product_name: product.product_name,
        brands: product.brands,
        categories_tags_en: product.categories_tags_en,
        categories_tags_ua: product.categories_tags_ua,
        nutriscore_grade: product.nutriscore_grade,
        ecoscore_grade: product.ecoscore_grade,
        ingredients_en: product.ingredients_en,
        ingredients_ua: product.ingredients_ua,
        allergens_en: product.allergens_en,
        allergens_ua: product.allergens_ua,
        packaging_en: product.packaging_en,
        packaging_ua: product.packaging_ua,
        nutriments: product.nutriments,
        nova_group: product.nova_group,
        quantity: product.quantity,
        serving_size: product.serving_size,
        serving_quantity: product.serving_quantity,
        image_url: product.image_url,
        analysis_ua: product.analysis_ua,
        analysis_en: product.analysis_en,
        source: product.source,
    };
}
