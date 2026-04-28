import Foundation
import CoreLocation

public struct MapResponse: Codable {
    public let count: Int
    public let points: [MapPoint]
}

public struct MapPoint: Codable, Identifiable {
    public let id: String
    public let lat: Double
    public let lon: Double
    public let name: String
    public let info: MapPointInfo
    public let details: MapPointDetails
    
    public var id_as_string: String { id }
    
    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
}

public struct MapPointInfo: Codable {
    public let address: String?
    public let operatorName: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case operatorName = "operator"
    }
}

public struct MapPointDetails: Codable {
    public let acceptedMaterials: [String]
    
    enum CodingKeys: String, CodingKey {
        case acceptedMaterials = "accepted_materials"
    }
}
