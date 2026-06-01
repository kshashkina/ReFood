import Foundation
import Amplify
import AWSAPIPlugin

enum SyncAPI {
    static func fetchAchievements() async throws -> AchievementsResponse {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/achievements")
        let data = try await Amplify.API.get(request: request)
        return try JSONDecoder().decode(AchievementsResponse.self, from: data)
    }
    
    static func fetchScans() async throws -> [String] {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/scans")
        let data = try await Amplify.API.get(request: request)
        let response = try JSONDecoder().decode(ScansResponse.self, from: data)
        return response.scans.map { $0.barcode }
    }
    
    static func fetchFavorites() async throws -> [String] {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/favorites")
        let data = try await Amplify.API.get(request: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let array = (json["favorites"] as? [[String: Any]]) ??
                        (json["scans"] as? [[String: Any]]) ??
                        (json["items"] as? [[String: Any]]) ?? []
            return array.compactMap { $0["barcode"] as? String }
        }
        return []
    }
    
    static func fetchDashboard() async throws -> DashboardResponse {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/dashboard")
        let data = try await Amplify.API.get(request: request)
        return try JSONDecoder().decode(DashboardResponse.self, from: data)
    }
}
