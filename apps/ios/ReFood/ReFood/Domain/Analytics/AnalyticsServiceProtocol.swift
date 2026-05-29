import Foundation

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEventProtocol)
    func setUserId(_ userId: String)
    func resetUser()
}
