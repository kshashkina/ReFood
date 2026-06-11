import Foundation

enum RecyclingEvent: AnalyticsEventProtocol {
    case screenView
    case backTap
    case selectTap(type: String)
    case findTap(type: String)
    
    var name: String {
        switch self {
        case .screenView: return "recycling_screen_view"
        case .backTap: return "recycling_back_tap"
        case .selectTap: return "recycling_select_tap"
        case .findTap: return "recycling_find_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .selectTap(let type): return ["type": type]
        case .findTap(let type): return ["type": type]
        default: return nil
        }
    }
}
