import CoreLocation
import SwiftUI

enum MapConstants {
    static let kyivCenter = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
    static let fetchThreshold: CLLocationDistance = 3000
    static let defaultZoom: CLLocationDistance = 3000
    static let maxFlightZoom: CLLocationDistance = 15000
    static let minFlightZoom: CLLocationDistance = 600
    
    enum Animation {
        static let flightBase: Double = 1.2
        static let quickFlight: Double = 0.6
        static let slowFlightMax: Double = 1.5
        static let toggleHeading: Double = 0.8
        static let focusRoute: Double = 1.0
        static let afterFlightDelay: Double = 0.35
    }
    
    enum UI {
        static let bannerPaddingBottom: CGFloat = 140
        static let buttonsTopOffset: CGFloat = 210
        static let sheetDetentFraction: CGFloat = 0.45
    }
}
