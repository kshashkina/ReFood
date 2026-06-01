import Foundation

enum SettingsEvent: AnalyticsEventProtocol {
    case screenView(state: String)
    case backTap
    case cameraTap
    case locationTap
    case termsTap
    case privacyTap
    case deleteAccountTap
    case deleteAccountModalView
    case deleteAccountCancelTap
    case deleteAccountConfirmTap
    
    var name: String {
        switch self {
        case .screenView: return "settings_screen_view"
        case .backTap: return "settings_back_tap"
        case .cameraTap: return "settings_camera_tap"
        case .locationTap: return "settings_location_tap"
        case .termsTap: return "settings_terms_tap"
        case .privacyTap: return "settings_privacy_tap"
        case .deleteAccountTap: return "settings_delete_account_tap"
        case .deleteAccountModalView: return "delete_account_modal_view"
        case .deleteAccountCancelTap: return "delete_account_cancel_tap"
        case .deleteAccountConfirmTap: return "delete_account_confirm_tap"
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
