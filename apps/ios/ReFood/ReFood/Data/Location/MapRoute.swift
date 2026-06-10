import Foundation
import CoreLocation

public struct MapRoute: Codable {
    public let mode: String
    public let distance: Double
    public let distanceUnits: String
    public let time: Double
    public let steps: [RouteStep]
    public let coordinates: [RouteCoordinate]
    
    public var polylineCoordinates: [CLLocationCoordinate2D] {
        coordinates.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
    }
}

public struct RouteStep: Codable, Identifiable {
    public var id = UUID()
    public let distance: Double
    public let time: Double
    public let instruction: String
    
    enum CodingKeys: String, CodingKey {
        case distance, time, instruction
    }
}

public struct RouteCoordinate: Codable {
    public let lat: Double
    public let lon: Double
}
