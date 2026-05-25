import Foundation

public protocol DashboardRepository {
    func getDailyDashboard() async throws -> DailyDashboardResponse
}
