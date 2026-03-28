import SwiftUI
import Combine

@MainActor
final class ProductComparisonViewModel: ObservableObject {
    @Published var productA: Product
    @Published var productB: Product
    
    @Published var aiResult: AIComparisonAnalysis? = nil
    @Published var isAnalyzing: Bool = false
    
    private let aiRepository: AIComparisonRepository
    
    init(
        productA: Product,
        productB: Product,
        aiRepository: AIComparisonRepository = AIComparisonRepositoryImpl()
    ) {
        self.productA = productA
        self.productB = productB
        self.aiRepository = aiRepository
    }
    
    func fetchAIAnalysis() async {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        
        do {
            let analysis = try await aiRepository.getComparison(
                barcodeA: productA.barcode,
                barcodeB: productB.barcode
            )
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.aiResult = analysis
                self.isAnalyzing = false
            }
        } catch {
            print("AI Loading Error: \(error)")
            withAnimation {
                self.isAnalyzing = false
            }
        }
    }
    
    enum ComparisonResult {
        case better, worse, equal, unknown
    }
    
    func compareNutrient(path: KeyPath<Nutriments, Double?>, lowerIsBetter: Bool = true) -> (ComparisonResult, ComparisonResult) {
        guard let valA = productA.nutriments?[keyPath: path],
              let valB = productB.nutriments?[keyPath: path] else {
            return (.unknown, .unknown)
        }
        
        if valA == valB {
            return (.equal, .equal)
        }
        
        let aIsLower = valA < valB
        
        if lowerIsBetter {
            return aIsLower ? (.better, .worse) : (.worse, .better)
        } else {
            return aIsLower ? (.worse, .better) : (.better, .worse)
        }
    }
}
