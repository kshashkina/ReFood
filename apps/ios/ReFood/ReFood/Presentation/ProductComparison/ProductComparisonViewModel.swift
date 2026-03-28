import SwiftUI
import Combine

@MainActor
final class ProductComparisonViewModel: ObservableObject {
    @Published var productA: Product
    @Published var productB: Product
    
    init(productA: Product, productB: Product) {
        self.productA = productA
        self.productB = productB
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
    
    func compareGrades(path: KeyPath<Product, String?>) -> (ComparisonResult, ComparisonResult) {
        let grades = ["a": 5, "b": 4, "c": 3, "d": 2, "e": 1]
        
        guard let gradeA = productA[keyPath: path]?.lowercased(),
              let gradeB = productB[keyPath: path]?.lowercased(),
              let scoreA = grades[gradeA],
              let scoreB = grades[gradeB] else {
            return (.unknown, .unknown)
        }
        
        if scoreA == scoreB {
            return (.equal, .equal)
        }
        
        return scoreA > scoreB ? (.better, .worse) : (.worse, .better)
    }
}
