import Foundation

enum NavigationEvent: AnalyticsEventProtocol {
    case tabTap(destination: String, source: MainTab)
    
    var name: String {
        switch self {
        case .tabTap(let destination, _):
            return "\(destination)_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .tabTap(_, let source):
            return ["screen_name": "\(source.stringValue)_screen"]
        }
    }
}
