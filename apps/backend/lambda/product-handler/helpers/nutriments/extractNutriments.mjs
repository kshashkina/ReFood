import { calculateTotalNutrients } from './calculateNutriments.mjs';

export function extractNutriments(nutriments, servingQuantity, totalQuantity) {
    const getNutrient = (key100g, keyServing) => {
        const val100g = nutriments[key100g] ?? nutriments[key100g.replace('-', '_')] ?? null;
        const valServingFromApi = nutriments[keyServing] ?? nutriments[keyServing.replace('-', '_')] ?? null;

        return {
            val100g,
            valServing: valServingFromApi ?? (servingQuantity ? calculateTotalNutrients(val100g, servingQuantity) : null),
            valTotal: totalQuantity ? calculateTotalNutrients(val100g, totalQuantity) : null
        };
    };

    const energy = getNutrient("energy-kcal_100g", "energy-kcal_serving");
    const proteins = getNutrient("proteins_100g", "proteins_serving");
    const fat = getNutrient("fat_100g", "fat_serving");
    const saturatedFat = getNutrient("saturated-fat_100g", "saturated-fat_serving");
    const carbohydrates = getNutrient("carbohydrates_100g", "carbohydrates_serving");
    const sugars = getNutrient("sugars_100g", "sugars_serving");
    const added_sugars = getNutrient("added-sugars_100g", "added_sugars_100g")
    const salt = getNutrient("salt_100g", "salt_serving");
    const caffeine = getNutrient("caffeine_100g", "caffeine_serving");

    return {
        energy_kcal_100g: energy.val100g,
        energy_kcal_serving: energy.valServing,
        energy_kcal_total: energy.valTotal,

        proteins_100g: proteins.val100g,
        proteins_serving: proteins.valServing,
        proteins_total: proteins.valTotal,

        fat_100g: fat.val100g,
        fat_serving: fat.valServing,
        fat_total: fat.valTotal,

        saturated_fat_100g: saturatedFat.val100g,
        saturated_fat_serving: saturatedFat.valServing,
        saturated_fat_total: saturatedFat.valTotal,

        carbohydrates_100g: carbohydrates.val100g,
        carbohydrates_serving: carbohydrates.valServing,
        carbohydrates_total: carbohydrates.valTotal,

        sugars_100g: sugars.val100g,
        sugars_serving: sugars.valServing,
        sugars_total: sugars.valTotal,

        salt_100g: salt.val100g,
        salt_serving: salt.valServing,
        salt_total: salt.valTotal,
        
        added_sugars_100g: added_sugars.val100g,
        added_sugars_serving: added_sugars.valServing,
        added_sugars_total: added_sugars.valTotal,

        caffeine_100g: caffeine.val100g,
        caffeine_serving: caffeine.valServing,
        caffeine_total: caffeine.valTotal
    };
}