import Foundation

public struct PackagingItem: Codable, Equatable, Hashable {
    public let numberOfUnits: Int?
    public let material: String?
    public let recycling: String?
    public let shape: String?

    enum CodingKeys: String, CodingKey {
        case numberOfUnits = "number_of_units"
        case material
        case recycling
        case shape
    }
}
