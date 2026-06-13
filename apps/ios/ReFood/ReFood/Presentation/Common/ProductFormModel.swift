import Foundation

public struct ProductFormModel {
    public var name: String = ""
    public var brand: String = ""
    public var quantity: String = ""
    public var ingredients: String = ""
    public var categories: String = ""
    public var allergens: String = ""
    public var nutriScore: String = ""
    public var ecoScore: String = ""
    
    public var nutrition = NutritionFormFields()
    public var packaging: [PackagingInput] = [PackagingInput()]

    public init() {} 
    
    public init(from p: Product) {
        self.name = p.productName ?? ""
        self.brand = p.brands ?? ""
        self.quantity = p.quantity ?? ""
        self.ingredients = p.ingredientsEn?.joined(separator: ", ") ?? ""
        self.categories = p.categoriesTagsEn?.joined(separator: ", ") ?? ""
        self.allergens = p.allergensEn?.joined(separator: ", ") ?? ""
        self.nutriScore = (p.nutriscoreGrade ?? "").uppercased()
        self.ecoScore = (p.ecoscoreGrade ?? "").uppercased()
        
        if let n = p.nutriments {
            self.nutrition.kcal = formatDouble(n.energyKcal100g)
            self.nutrition.proteins = formatDouble(n.proteins100g)
            self.nutrition.fats = formatDouble(n.fat100g)
            self.nutrition.carbs = formatDouble(n.carbohydrates100g)
            self.nutrition.saturatedFat = formatDouble(n.saturatedFat100g)
            self.nutrition.sugars = formatDouble(n.sugars100g)
            self.nutrition.addedSugars = formatDouble(n.addedSugars100g)
            self.nutrition.salt = formatDouble(n.salt100g)
            self.nutrition.caffeine = formatDouble(n.caffeine100g)
        }
        
        if let packs = p.packagingEn, !packs.isEmpty {
            self.packaging = packs.map { item in
                PackagingInput(shape: item.shape ?? "", material: item.material ?? "", recycling: item.recycling ?? "")
            }
        }
    }

    public func canSave(isEditing: Bool, isImageValid: Bool) -> Bool {
        let isBaseValid = !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                          !brand.trimmingCharacters(in: .whitespaces).isEmpty &&
                          !ingredients.trimmingCharacters(in: .whitespaces).isEmpty
        
        let isNutritionValid = nutrition.hasRequiredData
        
        return isEditing ? (isBaseValid && isNutritionValid) : (isBaseValid && isNutritionValid && isImageValid)
    }

    public func toProductRequest(barcode: String) -> ProductAdd {
        let nutrimentsRequest = NutrimentsAdd(
            addedSugars: parse(nutrition.addedSugars),
            proteins: parse(nutrition.proteins),
            energy: parse(nutrition.kcal),
            fat: parse(nutrition.fats),
            salt: parse(nutrition.salt),
            sugars: parse(nutrition.sugars),
            saturatedFat: parse(nutrition.saturatedFat),
            carbs: parse(nutrition.carbs),
            caffeine: parse(nutrition.caffeine)
        )
        
        let packagingRequest = packaging.compactMap { item -> PackagingItemAdd? in
            if item.shape.isEmpty && item.material.isEmpty { return nil }
            return PackagingItemAdd(
                material: item.material.isEmpty ? nil : item.material,
                shape: item.shape.isEmpty ? nil : item.shape,
                recycling: item.recycling.isEmpty ? nil : item.recycling
            )
        }
        
        var request = ProductAdd(
            barcode: barcode,
            productName: name,
            brands: brand,
            quantity: quantity,
            nutriments: nutrimentsRequest,
            packaging: packagingRequest
        )
        
        request.ingredients_text = ingredients.isEmpty ? nil : ingredients
        request.categories_tags = categories
        request.allergens_tags = allergens
        request.nutriscore_grade = nutriScore.lowercased()
        request.ecoscore_grade = ecoScore.lowercased()
        
        return request
    }

    private func parse(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
    
    private func formatDouble(_ val: Double?) -> String {
        guard let v = val else { return "" }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: v)) ?? ""
    }
}

public struct NutritionFormFields {
    public var kcal: String = ""
    public var proteins: String = ""
    public var fats: String = ""
    public var carbs: String = ""
    public var saturatedFat: String = ""
    public var sugars: String = ""
    public var addedSugars: String = ""
    public var salt: String = ""
    public var caffeine: String = ""

    public var hasRequiredData: Bool {
        !kcal.isEmpty && !proteins.isEmpty && !fats.isEmpty && !carbs.isEmpty
    }
}

public struct PackagingInput: Identifiable {
    public let id = UUID()
    public var shape: String = ""
    public var material: String = ""
    public var recycling: String = ""
    
    public init(shape: String = "", material: String = "", recycling: String = "") {
        self.shape = shape
        self.material = material
        self.recycling = recycling
    }
}
