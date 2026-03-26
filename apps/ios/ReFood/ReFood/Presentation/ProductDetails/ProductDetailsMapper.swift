import Foundation

struct ProductDetailsMapper {
    static func displayName(for product: Product) -> String {
        product.productName ?? "Unknown product"
    }
    static func brand(for product: Product) -> String? {
        product.brands
    }
    static func categoriesLine(for product: Product) -> String? {
        let tags = product.categoriesTagsEn ?? []
        return tags.isEmpty ? nil : tags.joined(separator: ", ")
    }

    static func ingredientsList(for product: Product) -> [String] {
        product.ingredientsEn ?? product.ingredientsUa ?? []
    }

    static func allergensList(for product: Product) -> [String] {
        product.allergensEn ?? product.allergensUa ?? []
    }

    static func aiAnalysis(for product: Product) -> String? {
        product.analysisEn ?? product.analysisUa
    }

    static func packagingItems(for product: Product) -> [(title: String, subtitle: String)] {
            let items = product.packagingEn ?? product.packagingUa ?? []
            
            return items.compactMap { item in
                let shape = item.shape?.capitalized ?? "Packaging element"
                let material = item.material?.capitalized ?? ""
                return (title: shape, subtitle: material)
            }
        }
}
