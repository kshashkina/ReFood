import Foundation

enum MapAPI {
    static func fetchLocations(lat: Double, lon: Double, materials: String?, radius: Int = 5000) async throws -> Data {
        let url = APIConfig.baseURL.appendingPathComponent("map").appendingPathComponent("locations")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        var queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "radius", value: "\(radius)")
        ]
        
        let materialsValue = (materials == nil || materials == "All") ? "all" : materials!.lowercased()
        queryItems.append(URLQueryItem(name: "materials", value: materialsValue))
        
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            throw NetworkError.invalidResponse
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw NetworkError.httpStatus(code: http.statusCode, body: body)
        }

        return data
    }
    
    static func fetchRoute(fromLat: Double, fromLon: Double, toLat: Double, toLon: Double, mode: String = "walk") async throws -> Data {
        let url = APIConfig.baseURL.appendingPathComponent("map").appendingPathComponent("route")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "fromLat", value: "\(fromLat)"),
            URLQueryItem(name: "fromLon", value: "\(fromLon)"),
            URLQueryItem(name: "toLat", value: "\(toLat)"),
            URLQueryItem(name: "toLon", value: "\(toLon)"),
            URLQueryItem(name: "mode", value: mode)
        ]
        
        guard let finalURL = components?.url else {
            throw NetworkError.invalidResponse
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
}
