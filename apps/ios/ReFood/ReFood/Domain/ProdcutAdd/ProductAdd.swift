import Foundation

public struct ProductAdd: Encodable {
    public var barcode: String
    public var productName: String
    public var brands: String
    public var quantity: String
    public var image_url: String?
    public var imageId: String?
    public var s3Key: String?
    public var ingredients_text: String?
    public var categories_tags: String?
    public var allergens_tags: String?
    public var nutriscore_grade: String?
    public var ecoscore_grade: String?
    public var nova_group: Int?
    public var nutriments: NutrimentsAdd
    public var packaging: [PackagingItemAdd]

    enum CodingKeys: String, CodingKey {
        case barcode, nutriments, packaging
        case productName = "product_name"
        case brands, quantity
        case image_url = "image_url"
        case imageId, s3Key
        case ingredients_text = "ingredients_text"
        case categories_tags = "categories_tags"
        case allergens_tags = "allergens_tags"
        case nutriscore_grade = "nutriscore_grade"
        case ecoscore_grade = "ecoscore_grade"
        case nova_group = "nova_group"
    }
    
    public init(
        barcode: String = "",
        productName: String = "",
        brands: String = "",
        quantity: String = "",
        nutriments: NutrimentsAdd = NutrimentsAdd(),
        packaging: [PackagingItemAdd] = []
    ) {
        self.barcode = barcode
        self.productName = productName
        self.brands = brands
        self.quantity = quantity
        self.categories_tags = ""
        self.allergens_tags = ""
        self.nutriments = nutriments
        self.packaging = packaging
    }
}
