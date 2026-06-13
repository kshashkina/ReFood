import Foundation

enum LoadingSheetEvent: AnalyticsEventProtocol {
    case productLoadingModalView
    case productLoadingSwipe(step: String)
    case productLoadingContinueTap
    case notFoundModalView
    case notFoundSwipe
    case notFoundTryAgainTap
    case notFoundAddTap
    
    var name: String {
        switch self {
        case .productLoadingModalView: return "product_loading_modal_view"
        case .productLoadingSwipe: return "product_loading_swipe"
        case .productLoadingContinueTap: return "product_loading_continue_tap"
        case .notFoundModalView: return "not_found_modal_view"
        case .notFoundSwipe: return "not_found_swipe"
        case .notFoundTryAgainTap: return "not_found_try_again_tap"
        case .notFoundAddTap: return "not_found_add_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .productLoadingSwipe(let step):
            return ["step": step]
        default:
            return nil
        }
    }
}
