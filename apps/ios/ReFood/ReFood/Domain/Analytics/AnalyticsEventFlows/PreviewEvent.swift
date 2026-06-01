import Foundation

enum PreviewEvent: AnalyticsEventProtocol {
    case screenView(barcode: String)
    case backTap
    case continueTap(mode: String)
    case scanAgainTap
    
    var name: String {
        switch self {
        case .screenView: return "preview_screen_view"
        case .backTap: return "preview_back_tap"
        case .continueTap: return "preview_continue_tap"
        case .scanAgainTap: return "preview_scan_again_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let barcode):
            return ["barcode": barcode]
        case .continueTap(let mode):
            return ["mode": mode]
        default:
            return nil
        }
    }
}
