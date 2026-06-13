import Foundation

public struct NutrimentsAdd: Encodable {
    public var added_sugars_100g: Double?
    public var proteins_100g: Double?
    public var energy_kcal_100g: Double?
    public var fat_100g: Double?
    public var salt_100g: Double?
    public var sugars_100g: Double?
    public var saturated_fat_100g: Double?
    public var carbohydrates_100g: Double?
    public var caffeine_100g: Double?

    public init(
        addedSugars: Double? = nil,
        proteins: Double? = nil,
        energy: Double? = nil,
        fat: Double? = nil,
        salt: Double? = nil,
        sugars: Double? = nil,
        saturatedFat: Double? = nil,
        carbs: Double? = nil,
        caffeine: Double? = nil
    ) {
        self.added_sugars_100g = addedSugars
        self.proteins_100g = proteins
        self.energy_kcal_100g = energy
        self.fat_100g = fat
        self.salt_100g = salt
        self.sugars_100g = sugars
        self.saturated_fat_100g = saturatedFat
        self.carbohydrates_100g = carbs
        self.caffeine_100g = caffeine
    }
}
