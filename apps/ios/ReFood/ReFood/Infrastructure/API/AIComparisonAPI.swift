import Foundation

enum AIComparisonAPI {
    static func fetchComparisonData(barcodeA: String, barcodeB: String) async throws -> Data {
        let basePath = APIConfig.baseURL
            .appendingPathComponent("product")
            .appendingPathComponent("compare")
            
        var components = URLComponents(url: basePath, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "barcodeA", value: barcodeA),
            URLQueryItem(name: "barcodeB", value: barcodeB)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
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
