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
}
