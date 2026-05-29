import Foundation

enum MainTab: String, Hashable {
    case home = "home"
    case search = "search"
    case map = "map"
    case profile = "profile"
    
    var stringValue: String { self.rawValue }
}
