import Foundation
import CoreLocation

public protocol LocationRepository {
    func getLocations(lat: Double, lon: Double, materials: String?) async throws -> [MapPoint]
}

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
}
