import Foundation

public protocol AIComparisonRepository {
    func getComparison(barcodeA: String, barcodeB: String) async throws -> AIComparisonAnalysis
}
