import Foundation

struct ProductDetailsMapper {

    static func displayName(for product: Product) -> String {
        if let v = clean(product.productName) { return v }
        if let v = clean(product.productNameEn) { return v }
        return "Unknown product"
    }

    static func brand(for product: Product) -> String? {
        clean(product.brands)
    }

    static func categoriesLine(for product: Product) -> String? {
        let tags = (product.categoriesTags ?? [])
            .compactMap { clean($0) }
            .map { $0.replacingOccurrences(of: "-", with: " ") }
            .map { $0.capitalized }

        return tags.isEmpty ? nil : tags.joined(separator: ", ")
    }

    static func ingredientsList(for product: Product) -> [String] {
        let raw = (product.ingredientsText?.isEmpty == false)
        ? (product.ingredientsText ?? "")
        : (product.ingredientsTextEn ?? "")

        let cleaned = clean(raw) ?? ""
        return cleaned.isEmpty ? [] : splitIngredients(cleaned)
    }

    static func allergensList(for product: Product) -> [String] {
        (product.allergensTags ?? [])
            .compactMap { clean($0) }
            .map { $0.capitalized }
    }

    static func packagingMaterials(for product: Product) -> [String] {
        let items = product.packaging ?? []
        let materials = items.compactMap { clean($0.material)?.capitalized }
        return materials
    }

    static func clean(_ s: String?) -> String? {
        guard var s, !s.isEmpty else { return nil }

        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if trimmed.lowercased() == "unknown" { return nil }
        for prefix in ["en:", "uk:", "de:", "fr:", "es:", "it:", "ua:"] {
            if s.hasPrefix(prefix) {
                s = String(s.dropFirst(prefix.count))
                break
            }
        }

        s = s.replacingOccurrences(of: "_", with: " ")
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }

    static func splitIngredients(_ text: String) -> [String] {
        var result: [String] = []
        var current = ""
        var depth = 0

        for ch in text {
            if ch == "(" { depth += 1 }
            if ch == ")" { depth = max(0, depth - 1) }

            if ch == "," && depth == 0 {
                let item = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !item.isEmpty { result.append(item) }
                current = ""
            } else {
                current.append(ch)
            }
        }

        let last = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !last.isEmpty { result.append(last) }

        return result
    }
}
