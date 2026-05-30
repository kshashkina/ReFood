import Foundation

enum ProfileEvent: AnalyticsEventProtocol {
    case screenView(state: String)
    case signInTap
    case achievementsTap
    case settingsTap
    case helpTap
    
    var name: String {
        switch self {
        case .screenView: return "profile_screen_view"
        case .signInTap: return "profile_sign_in_tap"
        case .achievementsTap: return "profile_achievements_tap"
        case .settingsTap: return "profile_settings_tap"
        case .helpTap: return "profile_help_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let state):
            return ["state": state]
        default:
            return nil
        }
    }
}
