import Foundation

public struct Nutriments: Codable, Equatable, Hashable {
    public let addedSugars100g: Double?
    public let proteins100g: Double?
    public let energyKcal100g: Double?
    public let fat100g: Double?
    public let salt100g: Double?
    public let sugars100g: Double?
    public let saturatedFat100g: Double?
    public let carbohydrates100g: Double?
    public let caffeine100g: Double?

    public let addedSugarsServing: Double?
    public let proteinsServing: Double?
    public let energyKcalServing: Double?
    public let fatServing: Double?
    public let saltServing: Double?
    public let sugarsServing: Double?
    public let saturatedFatServing: Double?
    public let carbohydratesServing: Double?
    public let caffeineServing: Double?

    enum CodingKeys: String, CodingKey {
        case addedSugars100g = "added_sugars_100g"
        case addedSugarsServing = "added_sugars_serving"
        case proteinsServing = "proteins_serving"
        case energyKcal100g = "energy_kcal_100g"
        case fat100g = "fat_100g"
        case salt100g = "salt_100g"
        case sugars100g = "sugars_100g"
        case sugarsServing = "sugars_serving"
        case saltServing = "salt_serving"
        case proteins100g = "proteins_100g"
        case saturatedFat100g = "saturated_fat_100g"
        case carbohydratesServing = "carbohydrates_serving"
        case saturatedFatServing = "saturated_fat_serving"
        case carbohydrates100g = "carbohydrates_100g"
        case caffeineServing = "caffeine_serving"
        case caffeine100g = "caffeine_100g"
        case energyKcalServing = "energy_kcal_serving"
        case fatServing = "fat_serving"
    }
}
