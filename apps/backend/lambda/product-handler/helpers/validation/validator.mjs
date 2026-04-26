export function validateProductInput(data) {
    const errors = [];

    if (!data.barcode) {
        errors.push("barcode is required");
    }

    if (!data.product_name ) {
        errors.push("product_name is required");
    }

    if (!data.ingredients_text || typeof data.ingredients_text !== 'string') {
        errors.push("ingredients_text is required and must be a string");
    }

    if (data.categories_tags && typeof data.categories_tags !== 'string') {
        errors.push("categories_tags must be a string");
    }

    if (data.allergens_tags && typeof data.allergens_tags !== 'string') {
        errors.push("allergens_tags must be a string");
    }

    if (!data.nutriments || typeof data.nutriments !== 'object') {
        errors.push("nutriments required and must be an object");
    }

    if (data.packaging && !Array.isArray(data.packaging)) {
        errors.push("packaging must be an array");
    }

    if (data.nutriscore_grade && !/^[a-eA-E]$/.test(data.nutriscore_grade)) {
        errors.push("nutriscore_grade must be a-e");
    }

    if (data.ecoscore_grade && !/^[a-eA-E]$/.test(data.ecoscore_grade)) {
        errors.push("ecoscore_grade must be a-e");
    }

    if (data.nova_group && (data.nova_group < 1 || data.nova_group > 4)) {
        errors.push("nova_group must be 1-4");
    }

    return {
        valid: errors.length === 0,
        errors
    };
}
