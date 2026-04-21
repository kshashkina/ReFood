import Foundation

public struct PackagingItemAdd: Encodable {
    public var material: String?
    public var shape: String?
    public var number_of_units: Int?
    public var recycling: String?
    
    public init(material: String? = nil, shape: String? = nil, number_of_units: Int? = 1, recycling: String? = nil) {
        self.material = material
        self.shape = shape
        self.number_of_units = number_of_units
        self.recycling = recycling
    }
}
