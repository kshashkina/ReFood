import Foundation
import SwiftData

struct ScannedHistoryItem: Identifiable, Hashable {
    let id: String
    let product: Product
    let scanDate: Date
    var isFavorite: Bool
}


@Model
final class ScannedHistoryModel {
    @Attribute(.unique) var id: String
    var productData: Data
    var scanDate: Date
    var isFavorite: Bool
    
    var productName: String
    var brand: String
    var imageUrl: String?
    
    init(
        id: String,
        productData: Data,
        scanDate: Date,
        isFavorite: Bool,
        productName: String,
        brand: String,
        imageUrl: String?
    ) {
        self.id = id
        self.productData = productData
        self.scanDate = scanDate
        self.isFavorite = isFavorite
        self.productName = productName
        self.brand = brand
        self.imageUrl = imageUrl
    }
}
