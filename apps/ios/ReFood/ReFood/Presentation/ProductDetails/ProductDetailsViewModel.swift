import Foundation
import Combine

@MainActor
final class ProductDetailsViewModel: ObservableObject {
    let product: Product
    private let languageProvider: LanguageProvider
    
    @Published var nutritionTab: ProductDetailsScreen.NutritionTab = .per100g
    
    init(product: Product, languageProvider: LanguageProvider) {
        self.product = product
        self.languageProvider = languageProvider
    }
    
    var displayName: String {
        product.productName ?? String(localized: "common_unknown")
    }
    
    var brand: String? {
        product.brands
    }
    
    var categoriesLine: String? {
        let tags = languageProvider.currentLanguageCode == "ua" ? product.categoriesTagsUa : product.categoriesTagsEn
        let validTags = tags ?? []
        return validTags.isEmpty ? nil : validTags.joined(separator: ", ")
    }
    
    var aiAnalysis: String? {
        languageProvider.currentLanguageCode == "ua" ? product.analysisUa : product.analysisEn
    }
    
    var ingredientsList: [String] {
        languageProvider.currentLanguageCode == "ua" ? (product.ingredientsUa ?? []) : (product.ingredientsEn ?? [])
    }
    
    var allergensList: [String] {
        languageProvider.currentLanguageCode == "ua" ? (product.allergensUa ?? []) : (product.allergensEn ?? [])
    }
    
    var packagingItems: [(title: String, subtitle: String)] {
        let items = languageProvider.currentLanguageCode == "ua" ? product.packagingUa : product.packagingEn
        let validItems = items ?? []
        
        return validItems.compactMap { item in
            let shape = item.shape?.capitalized ?? String(localized: "recycling_packaging_element")
            let material = item.material?.capitalized ?? ""
            return (title: shape, subtitle: material)
        }
    }
    
    var nutriScoreGrade: String {
        (product.nutriscoreGrade ?? "-").uppercased()
    }
    
    var ecoScoreGrade: String {
        (product.ecoscoreGrade ?? "-").uppercased()
    }
    
    var nutriSubtitleKey: String {
        switch (product.nutriscoreGrade ?? "").lowercased() {
        case "a": return "grade_excellent"
        case "b": return "grade_good"
        case "c": return "grade_average"
        case "d": return "grade_not_great"
        case "e": return "grade_poor"
        default: return "grade_unknown"
        }
    }
    
    var ecoSubtitleKey: String {
        switch (product.ecoscoreGrade ?? "").lowercased() {
        case "a", "b": return "grade_eco_friendly"
        case "c": return "grade_moderate"
        case "d", "e": return "grade_low"
        default: return "grade_unknown"
        }
    }
    
    func caloriesString() -> String {
        guard let v = tabValue(for: \.energyKcal100g, serving: \.energyKcalServing) else { return "—" }
        return "\(format(v)) kcal"
    }
    
    func gramsString(for path100g: KeyPath<Nutriments, Double?>, serving pathServing: KeyPath<Nutriments, Double?>) -> String {
        guard let v = tabValue(for: path100g, serving: pathServing) else { return "—" }
        return "\(format(v)) g"
    }
    
    private func tabValue(for path100g: KeyPath<Nutriments, Double?>, serving pathServing: KeyPath<Nutriments, Double?>) -> Double? {
        nutritionTab == .per100g ? product.nutriments?[keyPath: path100g] : product.nutriments?[keyPath: pathServing]
    }
    
    private func format(_ v: Double) -> String {
        let s = String(format: "%.1f", v)
        return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
    }
    
    func getShareText() -> String {
        let formatString = String(localized: "share_product_message")
        return String(format: formatString, displayName, product.barcode)
    }
}
