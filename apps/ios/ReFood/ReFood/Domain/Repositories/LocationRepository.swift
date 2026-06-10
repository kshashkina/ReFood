import Foundation
import CoreLocation

public protocol LocationRepository {
    func getLocations(lat: Double, lon: Double, materials: String?) async throws -> [MapPoint]
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, mode: String) async throws -> MapRoute
}

