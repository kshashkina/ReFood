import Foundation

protocol AnalyticsEventProtocol {
    var name: String { get }
    var properties: [String: Any]? { get }
}

extension AnalyticsEventProtocol {
    var properties: [String: Any]? { return nil }
}
