import Foundation

enum ComparisonEvent: AnalyticsEventProtocol {
    case screenView
    case backTap
    case aiInsightTap
    case aiInsightRetryTap
    
    var name: String {
        switch self {
        case .screenView: return "comparison_screen_view"
        case .backTap: return "comparison_back_tap"
        case .aiInsightTap: return "comparison_ai_insight_tap"
        case .aiInsightRetryTap: return "comparison_ai_insight_retry_tap"
        }
    }
    
    var properties: [String: Any]? {
        return nil
    }
}
