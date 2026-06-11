import Foundation

enum AppLifecycleEvent: AnalyticsEventProtocol {
    case firstLaunch
    case reinstall
    case accountDeleted
    
    var name: String {
        switch self {
        case .firstLaunch: return "first_launch"
        case .reinstall: return "reinstall"
        case .accountDeleted: return "account_deleted"
        }
    }
    
    var properties: [String: Any]? {
        return nil
    }
}
