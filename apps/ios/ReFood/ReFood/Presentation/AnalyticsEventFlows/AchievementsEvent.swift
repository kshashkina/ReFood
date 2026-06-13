import Foundation

enum AchievementsEvent: AnalyticsEventProtocol {
    case screenView(count: Int)
    case backTap
    
    var name: String {
        switch self {
        case .screenView: return "achievements_screen_view"
        case .backTap: return "achievements_back_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let count):
            return ["count": count]
        case .backTap:
            return nil
        }
    }
}
