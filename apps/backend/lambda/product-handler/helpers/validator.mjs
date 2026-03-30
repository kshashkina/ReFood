export function validateProductInput(data) {
    const errors = [];

    if (!data.barcode) {
        errors.push("barcode is required");
    }

    if (!data.product_name ) {
        errors.push("product_name is required");
    }

    if (data.categories_tags && !Array.isArray(data.categories_tags)) {
        errors.push("categories_tags must be an array");
    }

    if (data.allergens_tags && !Array.isArray(data.allergens_tags)) {
        errors.push("allergens_tags must be an array");
    }

    if (data.nutriments && typeof data.nutriments !== 'object') {
        errors.push("nutriments must be an object");
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
