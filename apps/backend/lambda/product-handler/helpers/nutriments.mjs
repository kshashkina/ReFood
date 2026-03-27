export function extractNutriments(nutriments) {
    return {
        energy_kcal_100g: nutriments["energy-kcal_100g"] ?? null,
        proteins_100g: nutriments.proteins_100g ?? null,
        fat_100g: nutriments.fat_100g ?? null,
        saturated_fat_100g: nutriments["saturated-fat_100g"] ?? null,
        carbohydrates_100g: nutriments.carbohydrates_100g ?? null,
        sugars_100g: nutriments.sugars_100g ?? null,
        added_sugars_100g: nutriments["added-sugars_100g"] ?? null,
        salt_100g: nutriments.salt_100g ?? null,
        caffeine_100g: nutriments.caffeine_100g ?? null,

        energy_kcal_serving: nutriments["energy-kcal_serving"] ?? null,
        proteins_serving: nutriments.proteins_serving ?? null,
        fat_serving: nutriments.fat_serving ?? null,
        saturated_fat_serving: nutriments["saturated-fat_serving"] ?? null,
        carbohydrates_serving: nutriments.carbohydrates_serving ?? null,
        sugars_serving: nutriments.sugars_serving ?? null,
        added_sugars_serving: nutriments["added-sugars_serving"] ?? null,
        salt_serving: nutriments.salt_serving ?? null,
        caffeine_serving: nutriments.caffeine_serving ?? null,
    };
}
