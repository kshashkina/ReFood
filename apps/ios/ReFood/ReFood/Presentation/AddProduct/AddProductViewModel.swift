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
    
    @Published var selectedUIImage: UIImage? = nil {
        didSet {
            if let image = selectedUIImage {
                processImageUpload(image)
            }
        }
    }
    @Published var isUploadingImage = false
    @Published var isImageValid = false
    @Published var imageError: String? = nil
    
    @Published var isSaving = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    
    private var s3Key: String = ""
    private var imageId: String = ""
    
    let barcode: String
    let grades = ["A", "B", "C", "D", "E"]
    
    private let repository: ProductRepository

    init(barcode: String, repository: ProductRepository = ProductRepositoryImpl()) {
        self.barcode = barcode
        self.repository = repository
    }
    
    var canSave: Bool {
        let nameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let brandValid = !brand.trimmingCharacters(in: .whitespaces).isEmpty
        let ingredientsValid = !ingredients.trimmingCharacters(in: .whitespaces).isEmpty
        let nutritionValid = !kcal.isEmpty && !proteins.isEmpty && !fats.isEmpty && !carbs.isEmpty
        
        return nameValid && brandValid && ingredientsValid && nutritionValid && isImageValid && !isUploadingImage
    }
    
    func processImageUpload(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        isUploadingImage = true
        isImageValid = false
        imageError = nil
        
        Task {
            do {
                let uploadInfo = try await repository.prepareUpload()
                self.s3Key = uploadInfo.s3Key
                self.imageId = uploadInfo.imageId
                try await repository.uploadImage(url: uploadInfo.uploadUrl, data: data)
                let validation = try await repository.validateImage(s3Key: s3Key, imageId: imageId)
                self.isImageValid = validation.isValid
                if !validation.isValid {
                    self.imageError = validation.error_en ?? "AI: Invalid image"
                }
            } catch {
                self.imageError = "Upload failed: \(error.localizedDescription)"
            }
            isUploadingImage = false
        }
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
            try await repository.finalizeAndAdd(
                product: newProduct,
                s3Key: s3Key,
                imageId: imageId
            )
            isSuccess = true
        } catch {
            self.error = "Saving failed: \(error.localizedDescription)"
        }
        isSaving = false
    }
}
