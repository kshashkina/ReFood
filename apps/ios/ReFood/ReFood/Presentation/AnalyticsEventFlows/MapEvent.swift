import Foundation

enum MapEvent: AnalyticsEventProtocol {
    case screenView
    case filterTap(filter: String)
    case centerTap(flow: String)
    case pointTap
    case pointModalView
    case pointRouteTap(type: String)
    case pointCloseTap
    case searchTap
    case routeCloseTap
    case routeSortedTap
    
    case locationModalView
    case locationAccessAllow
    case locationAccessDeny
    case locationDeniedModalView
    case locationDeniedSettingsTap
    case locationDeniedCloseTap
    
    var name: String {
        switch self {
        case .screenView: return "map_screen_view"
        case .filterTap: return "map_filter_tap"
        case .centerTap: return "map_center_tap"
        case .pointTap: return "map_point_tap"
        case .pointModalView: return "map_point_modal_view"
        case .pointRouteTap: return "map_point_route_tap"
        case .pointCloseTap: return "map_point_close_tap"
        case .searchTap: return "map_search_tap"
        case .routeCloseTap: return "map_route_close_tap"
        case .routeSortedTap: return "map_route_sorted_tap"
            
        case .locationModalView: return "location_access_modal_view"
        case .locationAccessAllow: return "location_access_allow"
        case .locationAccessDeny: return "location_access_deny"
        case .locationDeniedModalView: return "location_access_denied_modal_view"
        case .locationDeniedSettingsTap: return "location_access_denied_settings_tap"
        case .locationDeniedCloseTap: return "location_access_denied_close_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .filterTap(let filter):
            return ["filter": filter]
        case .centerTap(let flow):
            return ["flow": flow]
        case .pointRouteTap(let type):
            return ["type": type]
        default:
            return nil
        }
    }
}
