import Foundation

final class DashboardRepositoryImpl: DashboardRepository {
    func getDailyDashboard() async throws -> DailyDashboardResponse {
        do {
            let data = try await DashboardAPI.fetchDailyDashboard()
            let decoder = JSONDecoder()
            return try decoder.decode(DailyDashboardResponse.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch is DecodingError {
            throw NetworkError.invalidResponse
        } catch {
            throw error
        }
    }
}
