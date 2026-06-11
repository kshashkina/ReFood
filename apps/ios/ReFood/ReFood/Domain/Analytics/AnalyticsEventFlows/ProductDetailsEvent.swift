import Foundation

enum ProductDetailsEvent: AnalyticsEventProtocol {
    case screenView(barcode: String)
    case backTap
    case likeTap(barcode: String)
    case shareTap(barcode: String)
    case editTap
    case toggleTap(mode: String)
    case sortTap
    case compareTap
    
    var name: String {
        switch self {
        case .screenView: return "product_details_screen_view"
        case .backTap: return "product_details_back_tap"
        case .likeTap: return "product_details_like_tap"
        case .shareTap: return "product_details_share_tap"
        case .editTap: return "product_details_edit_tap"
        case .toggleTap: return "product_details_toggle_tap"
        case .sortTap: return "product_details_sort_tap"
        case .compareTap: return "product_details_compare_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let barcode): return ["barcode": barcode]
        case .likeTap(let barcode): return ["barcode": barcode]
        case .shareTap(let barcode): return ["barcode": barcode]
        case .toggleTap(let mode): return ["mode": mode]
        default: return nil
        }
    }
}
