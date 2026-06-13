import Foundation

enum NoInternetEvent: AnalyticsEventProtocol {
    case noInternetModalView
    case noInternetOkTap
    var name: String {
        switch self {
        case .noInternetModalView: return "no_internet_modal_view"
        case .noInternetOkTap: return "no_internet_ok_tap"
        }
    }
    
    var properties: [String: Any]? {
        return nil
    }
}
