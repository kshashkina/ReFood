import Foundation
import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    var currentLocation: CLLocation? { get }
    func requestAuthorization()
    func startUpdating()
}

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var currentLocation: CLLocation? {
        manager.location
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
}
