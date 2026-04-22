import SwiftUI
import Combine

struct PackagingInput: Identifiable {
    let id = UUID()
    var shape: String = ""
    var material: String = ""
    var recycling: String = ""
}

@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var quantity: String = ""
    @Published var ingredients: String = ""
    @Published var categories: String = ""
    @Published var allergens: String = ""
    
    @Published var packagingItems: [PackagingInput] = [PackagingInput()]
    
    @Published var nutriScore: String = ""
    @Published var ecoScore: String = ""
    
    @Published var kcal: String = ""
    @Published var proteins: String = ""
    @Published var fats: String = ""
    @Published var carbs: String = ""
    @Published var saturatedFat: String = ""
    @Published var sugars: String = ""
    @Published var addedSugars: String = ""
    @Published var salt: String = ""
    @Published var caffeine: String = ""
    
    @Published var isSaving = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    
    let barcode: String
    let grades = ["A", "B", "C", "D", "E"]
    
    init(barcode: String) {
        self.barcode = barcode
    }
    
    var canSave: Bool {
        let nameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let brandValid = !brand.trimmingCharacters(in: .whitespaces).isEmpty
        let ingredientsValid = !ingredients.trimmingCharacters(in: .whitespaces).isEmpty
        let nutritionValid = !kcal.isEmpty && !proteins.isEmpty && !fats.isEmpty && !carbs.isEmpty
        
        return nameValid && brandValid && ingredientsValid && nutritionValid
    }
    
    func addPackagingField() {
        packagingItems.append(PackagingInput())
    }
    
    private func toDouble(_ text: String) -> Double? {
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }
    
    func saveProduct() async {
        guard canSave else { return }
        isSaving = true
        error = nil
        
        let nutriments = NutrimentsAdd(
            addedSugars: toDouble(addedSugars),
            proteins: toDouble(proteins),
            energy: toDouble(kcal),
            fat: toDouble(fats),
            salt: toDouble(salt),
            sugars: toDouble(sugars),
            saturatedFat: toDouble(saturatedFat),
            carbs: toDouble(carbs),
            caffeine: toDouble(caffeine)
        )
        
        let packaging = packagingItems.compactMap { item -> PackagingItemAdd? in
            if item.shape.isEmpty && item.material.isEmpty { return nil }
            return PackagingItemAdd(
                material: item.material.isEmpty ? nil : item.material,
                shape: item.shape.isEmpty ? nil : item.shape,
                recycling: item.recycling.isEmpty ? nil : item.recycling
            )
        }
        
        var newProduct = ProductAdd(
            barcode: barcode,
            productName: name,
            brands: brand,
            quantity: quantity,
            nutriments: nutriments,
            packaging: packaging
        )
        
        newProduct.ingredients_text = ingredients.isEmpty ? nil : ingredients
        newProduct.categories_tags = categories.isEmpty ? "" : categories
        newProduct.allergens_tags = allergens.isEmpty ? "" : allergens
        newProduct.nutriscore_grade = nutriScore.isEmpty ? nil : nutriScore.lowercased()
        newProduct.ecoscore_grade = ecoScore.isEmpty ? nil : ecoScore.lowercased()
        
        do {
            try await ProductAPI.addProduct(product: newProduct)
            isSuccess = true
        } catch {
            self.error = "Error: \(error.localizedDescription)"
        }
        isSaving = false
    }
}
