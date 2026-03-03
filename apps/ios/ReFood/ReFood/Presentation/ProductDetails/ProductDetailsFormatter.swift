import SwiftUI

struct ProductDetailsFormatter {
    static func gradeColor(_ grade: String?) -> Color {
        switch (grade ?? "").lowercased() {
        case "a": return Color(red: 144/255, green: 240/255, blue: 71/255)
        case "b": return Color(red: 179/255, green: 243/255, blue: 87/255)
        case "c": return Color(red: 245/255, green: 221/255, blue: 77/255)
        case "d": return Color(red: 255/255, green: 163/255, blue: 62/255)
        case "e": return Color(red: 255/255, green: 84/255,  blue: 84/255)  
        default:  return Color.white.opacity(0.45)
        }
    }

    static func nutriSubtitle(for grade: String?) -> String {
        switch (grade ?? "").lowercased() {
        case "a": return "Excellent"
        case "b": return "Good quality"
        case "c": return "Average"
        case "d": return "Not great"
        case "e": return "Poor"
        default: return "—"
        }
    }

    static func ecoSubtitle(for grade: String?) -> String {
        switch (grade ?? "").lowercased() {
        case "a", "b": return "Eco-friendly"
        case "c": return "Moderate"
        case "d", "e": return "Low"
        default: return "—"
        }
    }

    static func proteins(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.proteins100g : product.nutriments?.proteinsServing
    }
    static func fat(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.fat100g : product.nutriments?.fatServing
    }
    static func saturatedFat(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.saturatedFat100g : product.nutriments?.saturatedFatServing
    }
    static func carbs(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.carbohydrates100g : product.nutriments?.carbohydratesServing
    }
    static func sugars(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.sugars100g : product.nutriments?.sugarsServing
    }
    static func salt(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.salt100g : product.nutriments?.saltServing
    }
    static func kcal(product: Product, tab: ProductDetailsScreen.NutritionTab) -> Double? {
        tab == .per100g ? product.nutriments?.energyKcal100g : product.nutriments?.energyKcalServing
    }

    static func caloriesString(product: Product, tab: ProductDetailsScreen.NutritionTab) -> String {
        guard let v = kcal(product: product, tab: tab) else { return "—" }
        return "\(format(v)) kcal"
    }

    static func gramsString(_ v: Double?) -> String {
        guard let v else { return "—" }
        return "\(format(v)) g"
    }

    static func format(_ v: Double) -> String {
        let s = String(format: "%.1f", v)
        return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
    }
}
