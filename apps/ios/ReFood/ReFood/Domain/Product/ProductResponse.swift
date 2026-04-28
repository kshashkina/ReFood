import Foundation

public struct ProductResponse: Decodable, Equatable {
    public let source: String
    public let product: Product
}
