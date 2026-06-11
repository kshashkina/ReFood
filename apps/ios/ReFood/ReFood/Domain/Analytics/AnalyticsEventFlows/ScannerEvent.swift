import Foundation

enum ScannerEvent: AnalyticsEventProtocol {
    case cameraAccessModalView
    case cameraAccessAllow
    case cameraAccessDeny
    case cameraAccessDeniedModalView
    case cameraAccessDeniedCloseTap
    case cameraAccessDeniedSettingsTap
    case screenView
    case closeTap
    case torchTap(mode: String)
    case manualTap
    case scanTap
    
    var name: String {
        switch self {
        case .cameraAccessModalView: return "camera_access_modal_view"
        case .cameraAccessAllow: return "camera_access_allow"
        case .cameraAccessDeny: return "camera_access_deny"
        case .cameraAccessDeniedModalView: return "camera_access_denied_modal_view"
        case .cameraAccessDeniedCloseTap: return "camera_access_denied_close_tap"
        case .cameraAccessDeniedSettingsTap: return "camera_access_denied_settings_tap"
        case .screenView: return "scanner_screen_view"
        case .closeTap: return "scanner_close_tap"
        case .torchTap: return "scanner_torch_tap"
        case .manualTap: return "scanner_manual_tap"
        case .scanTap: return "scanner_scan_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .torchTap(let mode):
            return ["mode": mode]
        default:
            return nil
        }
    }
}
