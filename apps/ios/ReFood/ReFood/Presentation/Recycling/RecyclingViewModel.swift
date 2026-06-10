import Foundation
import Combine

@MainActor
final class RecyclingViewModel: ObservableObject {
    private let product: Product
    private let languageProvider: LanguageProvider
    private let metricsRepository: MetricsRepository
    
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
    
    var combinedMaterialsFilter: String {
        guard let packaging = product.packagingEn else {
            return "all"
        }
        
        let materials = packaging.compactMap { item -> String? in
            guard let material = item.material?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                  !material.isEmpty else { return nil }
            return material
        }
        var seen = Set<String>()
        let uniqueMaterials = materials.filter { seen.insert($0).inserted }
        
        if uniqueMaterials.isEmpty {
            return "all"
        }
        let result = uniqueMaterials.joined(separator: ",")
        return result
    }
    
    private func categoryTitle(for category: RecyclingCategory) -> String {
        languageProvider.currentLanguageCode == "ua" ? category.titleUa : category.titleEn
    }
    
    private func categorySteps(for category: RecyclingCategory) -> [String] {
        languageProvider.currentLanguageCode == "ua" ? category.prepStepsUa : category.prepStepsEn
    }
    
}
