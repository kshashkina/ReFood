import Foundation

enum RecyclingEvent: AnalyticsEventProtocol {
    case screenView
    case backTap
    case findTap(type: String)
    
    var name: String {
        switch self {
        case .screenView: return "recycling_screen_view"
        case .backTap: return "recycling_back_tap"
        case .findTap: return "recycling_find_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .findTap(let type): return ["type": type]
        default: return nil
        }
    }
}
