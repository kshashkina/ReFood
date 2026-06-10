import Foundation
import CoreLocation

final class LocationRepositoryImpl: LocationRepository {
    
    func getLocations(lat: Double, lon: Double, materials: String?) async throws -> [MapPoint] {
        do {
            let data = try await MapAPI.fetchLocations(lat: lat, lon: lon, materials: materials)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MapResponse.self, from: data)
            return response.points
            
        } catch let error as NetworkError {
            throw error
        } catch is DecodingError {
            throw NetworkError.invalidResponse
        } catch {
            throw error
        }
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, mode: String) async throws -> MapRoute {
            do {
                let data = try await MapAPI.fetchRoute(
                    fromLat: from.latitude,
                    fromLon: from.longitude,
                    toLat: to.latitude,
                    toLon: to.longitude,
                    mode: mode
                )
                let decoder = JSONDecoder()
                return try decoder.decode(MapRoute.self, from: data)
            } catch {
                throw NetworkError.invalidResponse
            }
        }
}
