import Foundation

enum ManualInputEvent: AnalyticsEventProtocol {
    case screenView
    case backTap
    case formTap
    case continueTap
    case doneTap
    
    var name: String {
        switch self {
        case .screenView: return "manual_input_screen_view"
        case .backTap: return "manual_input_back_tap"
        case .formTap: return "manual_input_form_tap"
        case .continueTap: return "manual_input_continue_tap"
        case .doneTap: return "manual_input_done_tap"
        }
    }
    
    var properties: [String: Any]? {
        return nil
    }
}
