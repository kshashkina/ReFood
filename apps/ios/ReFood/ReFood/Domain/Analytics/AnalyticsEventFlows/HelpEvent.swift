import Foundation

enum HelpEvent: AnalyticsEventProtocol {
    case screenView
    case backTap
    case faqTap(id: Int)
    case emailTap
    
    var name: String {
        switch self {
        case .screenView: return "help_screen_view"
        case .backTap: return "help_back_tap"
        case .faqTap: return "help_faq_tap"
        case .emailTap: return "help_email_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .faqTap(let id):
            return ["id": id]
        default:
            return nil
        }
    }
}
