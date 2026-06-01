import Foundation

enum HomeEvent: AnalyticsEventProtocol {
    case screenView
    case articleTap
    case seeAllTap
    case productTap(barcode: String)
    
    var name: String {
        switch self {
        case .screenView: return "home_screen_view"
        case .articleTap: return "home_article_tap"
        case .seeAllTap: return "home_all_tap"
        case .productTap: return "home_product_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .productTap(let barcode):
            return ["barcode": barcode]
        default:
            return nil
        }
    }
}
