import Foundation

public struct AIComparisonAnalysis: Decodable, Equatable {
    public let comparisonEn: String?
    public let comparisonUa: String?
    public let winnerBarcode: String?
    public let keyDifferencesEn: [String]?
    public let keyDifferencesUa: [String]?

    enum CodingKeys: String, CodingKey {
        case comparisonEn = "comparison_en"
        case comparisonUa = "comparison_ua"
        case winnerBarcode = "winner_barcode"
        case keyDifferencesEn = "key_differences_en"
        case keyDifferencesUa = "key_differences_ua"
    }
}
