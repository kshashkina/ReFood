import Foundation
import UIKit
@testable import ReFood

final class MockAIComparisonRepository: AIComparisonRepository {
    var shouldReturnError = false
    var mockResult: AIComparisonAnalysis?
    var getComparisonCalled = false
    var receivedBarcodeA: String?
    var receivedBarcodeB: String?
    
    func getComparison(barcodeA: String, barcodeB: String) async throws -> AIComparisonAnalysis {
        getComparisonCalled = true
        receivedBarcodeA = barcodeA
        receivedBarcodeB = barcodeB
        
        if shouldReturnError {
            throw NSError(domain: "TestError", code: 500)
        }
        
        guard let mockResult else {
            fatalError("Please add mockResult to the test")
        }
        
        return mockResult
    }
}

final class MockLanguageProvider: LanguageProvider {
    var currentLanguageCode: String = "en"
}
