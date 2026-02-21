import Foundation

public struct Product: Decodable, Equatable {
    public let ingredientsTextEn: String?
    public let productNameEn: String?
    public let novaGroup: Int?
    public let ecoscoreGrade: String?
    public let packaging: [PackagingItem]?
    public let servingSize: String?
    public let brands: String?
    public let imageUrl: String?
    public let nutriscoreGrade: String?
    public let barcode: String
    public let quantity: String?
    public let ingredientsText: String?
    public let categoriesTags: [String]?
    public let productName: String?
    public let allergensTags: [String]?
    public let nutriments: Nutriments?
    public let ingredientsAnalysisTags: [String]?

    enum CodingKeys: String, CodingKey {
        case ingredientsTextEn = "ingredients_text_en"
        case productNameEn = "product_name_en"
        case novaGroup = "nova_group"
        case ecoscoreGrade = "ecoscore_grade"
        case packaging
        case servingSize = "serving_size"
        case brands
        case imageUrl = "image_url"
        case nutriscoreGrade = "nutriscore_grade"
        case barcode
        case quantity
        case ingredientsText = "ingredients_text"
        case categoriesTags = "categories_tags"
        case productName = "product_name"
        case allergensTags = "allergens_tags"
        case nutriments
        case ingredientsAnalysisTags = "ingredients_analysis_tags"
    }
}
