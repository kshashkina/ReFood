import Foundation
import Combine

@MainActor
final class ProductComparisonViewModel: ObservableObject {
    @Published var productA: Product
    @Published var productB: Product
    @Published var aiResult: AIComparisonAnalysis? = nil
    @Published var isAnalyzing: Bool = false
    @Published var aiError: String? = nil
    
    private let aiRepository: AIComparisonRepository
    private let languageProvider: LanguageProvider
    
    init(
        productA: Product,
        productB: Product,
        aiRepository: AIComparisonRepository,
        languageProvider: LanguageProvider
    ) {
        self.productA = productA
        self.productB = productB
        self.aiRepository = aiRepository
        self.languageProvider = languageProvider
    }
    
    var hasAIError: Bool {
        aiError != nil
    }
    
    func fetchAIAnalysis() async {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        aiError = nil
        
        do {
            let analysis = try await aiRepository.getComparison(
                barcodeA: productA.barcode,
                barcodeB: productB.barcode
            )
            
            self.aiResult = analysis
            self.isAnalyzing = false
        } catch {
            self.isAnalyzing = false
            self.aiError = "comparison_ai_error_message"
        }
    }
    
    var aiComparisonText: String? {
        languageProvider.currentLanguageCode == "ua" ? aiResult?.comparisonUa : aiResult?.comparisonEn
    }
    
    var aiDifferences: [String]? {
        languageProvider.currentLanguageCode == "ua" ? aiResult?.keyDifferencesUa : aiResult?.keyDifferencesEn
    }
    
    func isWinner(product: Product) -> Bool {
        guard let winner = aiResult?.winnerBarcode else { return false }
        return product.barcode == winner
    }
    
    func displayName(for product: Product) -> String {
        product.productName ?? "common_unknown"
    }
    
    func primaryBrand(for product: Product) -> String {
        product.brands?.components(separatedBy: ",").first ?? ""
    }
    
    func formattedGrade(for product: Product, path: KeyPath<Product, String?>) -> String {
        product[keyPath: path]?.uppercased() ?? "-"
    }
    
    enum ComparisonResult {
        case better, worse, equal, unknown
    }
    
    struct NutrientRowData {
        let valA: String
        let valB: String
        let resA: ComparisonResult
        let resB: ComparisonResult
    }
    
    func getNutrientData(path: KeyPath<Nutriments, Double?>, suffix: String, lowerIsBetter: Bool) -> NutrientRowData {
        let valA = productA.nutriments?[keyPath: path]
        let valB = productB.nutriments?[keyPath: path]
        
        guard let vA = valA, let vB = valB else {
            return NutrientRowData(
                valA: formatOptional(valA, suffix),
                valB: formatOptional(valB, suffix),
                resA: .unknown,
                resB: .unknown
            )
        }
        
        let strA = formatValue(vA, suffix)
        let strB = formatValue(vB, suffix)
        
        if vA == vB {
            return NutrientRowData(valA: strA, valB: strB, resA: .equal, resB: .equal)
        }
        
        let aIsBetter = lowerIsBetter ? (vA < vB) : (vA > vB)
        
        return NutrientRowData(
            valA: strA,
            valB: strB,
            resA: aIsBetter ? .better : .worse,
            resB: aIsBetter ? .worse : .better
        )
    }
    
    private func formatValue(_ value: Double, _ suffix: String) -> String {
        String(format: "%.1f %@", value, suffix)
    }
    
    private func formatOptional(_ value: Double?, _ suffix: String) -> String {
        guard let value = value else { return "-" }
        return formatValue(value, suffix)
    }
}
