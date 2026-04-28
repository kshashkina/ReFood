import Foundation

public struct Product: Decodable, Equatable, Hashable {
    public var barcode: String = ""
    public let productName: String?
    public let brands: String?
    public let quantity: String?
    public let imageUrl: String?
    public let analysisEn: String?
    public let analysisUa: String?
    public let categoriesTagsEn: [String]?
    public let categoriesTagsUa: [String]?
    public let ingredientsEn: [String]?
    public let ingredientsUa: [String]?
    public let allergensEn: [String]?
    public let allergensUa: [String]?
    public let packagingEn: [PackagingItem]?
    public let packagingUa: [PackagingItem]?
    public let nutriscoreGrade: String?
    public let ecoscoreGrade: String?
    public let novaGroup: Int?
        public let nutriments: Nutriments?

    enum CodingKeys: String, CodingKey {
        case brands, quantity, nutriments
        case productName = "product_name"
        case imageUrl = "image_url"
        case analysisEn = "analysis_en"
        case analysisUa = "analysis_ua"
        case categoriesTagsEn = "categories_tags_en"
        case categoriesTagsUa = "categories_tags_ua"
        case ingredientsEn = "ingredients_en"
        case ingredientsUa = "ingredients_ua"
        case allergensEn = "allergens_en"
        case allergensUa = "allergens_ua"
        case packagingEn = "packaging_en"
        case packagingUa = "packaging_ua"
        case nutriscoreGrade = "nutriscore_grade"
        case ecoscoreGrade = "ecoscore_grade"
        case novaGroup = "nova_group"
    }
}
