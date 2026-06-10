import Foundation

enum DashboardAPI {
    static func fetchDailyDashboard() async throws -> Data {
        let url = APIConfig.baseURL.appendingPathComponent("daily-dashboard")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        
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
