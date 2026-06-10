import Foundation
import Combine

@MainActor
final class RecyclingViewModel: ObservableObject {
    private let product: Product
    private let languageProvider: LanguageProvider
    private let metricsRepository: MetricsRepository
    @Published var selectedWasteType: WasteType?
    
    init(
        product: Product,
        languageProvider: LanguageProvider,
        metricsRepository: MetricsRepository
    ) {
        self.product = product
        self.languageProvider = languageProvider
        self.metricsRepository = metricsRepository
    }
    
    struct ComponentViewData: Identifiable {
        let id = UUID()
        let shapeTitle: String
        let materialTitle: String
        let categoryTitle: String
        let preparationSteps: [String]
    }
    
    struct WasteType: Identifiable {
        let id = UUID()
        let emoji: String
        let titleKey: String
        let filterKey: String
    }
    
    var productName: String {
        product.productName ?? String(localized: "common_unknown")
    }
    
    var primaryBrand: String {
        product.brands?.components(separatedBy: ",").first ?? ""
    }
    
    private var currentPackaging: [PackagingItem]? {
        languageProvider.currentLanguageCode == "ua" ? product.packagingUa : product.packagingEn
    }
    
    var hasPackagingData: Bool {
        !components.isEmpty
    }
    
    var components: [ComponentViewData] {
        guard let packaging = currentPackaging else { return [] }
        
        return packaging.map { item in
            let category = RecyclingCategory.from(material: item.material)
            
            return ComponentViewData(
                shapeTitle: item.shape?.capitalized ?? String(localized: "recycling_packaging_element"),
                materialTitle: item.material?.capitalized ?? String(localized: "recycling_unknown_material"),
                categoryTitle: categoryTitle(for: category),
                preparationSteps: categorySteps(for: category)
            )
        }
    }
    
    let standardWasteTypes: [WasteType] = [
        WasteType(emoji: "📄", titleKey: "recycling_type_paper", filterKey: "filter_paper"),
        WasteType(emoji: "♻️", titleKey: "recycling_type_plastic", filterKey: "filter_plastic"),
        WasteType(emoji: "🫙", titleKey: "recycling_type_glass", filterKey: "filter_glass"),
        WasteType(emoji: "🔩", titleKey: "recycling_type_metal", filterKey: "filter_metal"),
        WasteType(emoji: "🌱", titleKey: "recycling_type_organic", filterKey: "filter_all"),
        WasteType(emoji: "🗑️", titleKey: "recycling_type_mixed", filterKey: "filter_all")
    ]
    
    private func categoryTitle(for category: RecyclingCategory) -> String {
        languageProvider.currentLanguageCode == "ua" ? category.titleUa : category.titleEn
    }
    
    private func categorySteps(for category: RecyclingCategory) -> [String] {
        languageProvider.currentLanguageCode == "ua" ? category.prepStepsUa : category.prepStepsEn
    }
    
}
