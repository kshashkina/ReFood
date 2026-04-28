import Foundation
import Combine

@MainActor
final class ProductPreviewViewModel: ObservableObject {
    let product: Product
    let firstProductForComparison: Product?
    private let languageProvider: LanguageProvider
    
    init(product: Product, firstProductForComparison: Product? = nil, languageProvider: LanguageProvider) {
        self.product = product
        self.firstProductForComparison = firstProductForComparison
        self.languageProvider = languageProvider
    }
    
    var imageUrl: URL? {
        URL(string: product.imageUrl ?? "")
    }
    
    var productName: String {
        product.productName ?? String(localized: "common_unknown")
    }
    
    var brandName: String {
        product.brands ?? ""
    }
    
    var continueButtonTitle: String {
        if let first = firstProductForComparison {
            let brand = first.brands?.components(separatedBy: ",").first ?? String(localized: "preview_previous_item")
            return String(format: String(localized: "preview_btn_compare"), brand)
        }
        return String(localized: "preview_btn_continue")
    }
}
