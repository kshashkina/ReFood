import Foundation

enum SearchEvent: AnalyticsEventProtocol {
    case screenView(count: Int)
    case searchTap
    case closeTap
    case toggleAllTap
    case toggleFavoriteTap
    case likeTap(mode: String, toggle: String, barcode: String)
    case productTap(barcode: String)
    case deleteProductTap(barcode: String)
    
    var name: String {
        switch self {
        case .screenView: return "search_screen_view"
        case .searchTap: return "search_select_tap"
        case .closeTap: return "search_close_tap"
        case .toggleAllTap: return "search_toggle_all_tap"
        case .toggleFavoriteTap: return "search_toggle_favorite_tap"
        case .likeTap: return "search_like_tap"
        case .productTap: return "search_product_tap"
        case .deleteProductTap: return "search_delete_product_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let count):
            return ["count": count]
        case .likeTap(let mode, let toggle, let barcode):
            return [
                "mode": mode,
                "toggle": toggle,
                "barcode": barcode
            ]
        case .productTap(let barcode):
            return ["barcode": barcode]
        case .deleteProductTap(let barcode):
            return ["barcode": barcode]
        default:
            return nil
        }
    }
}
