import Foundation

struct RouteFormatter {
    static func distance(_ meters: Double) -> String {
        if meters >= 1000 {
            let km = meters / 1000.0
            return String(format: NSLocalizedString("route_dist_km", comment: ""), km)
        }
        return String(format: NSLocalizedString("route_dist_m", comment: ""), Int(meters))
    }
    
    static func time(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        if mins >= 60 {
            let hours = mins / 60
            let remainingMins = mins % 60
            return String(format: NSLocalizedString("route_time_h_m", comment: ""), hours, remainingMins)
        }
        return String(format: NSLocalizedString("route_time_m", comment: ""), mins)
    }
}
