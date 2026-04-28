import Foundation
import CoreLocation

public enum LocationPermissionStatus: Equatable {
    case authorized, notDetermined, denied, restricted
}

public protocol LocationPermissionServicing {
    func status() -> LocationPermissionStatus
    func requestAccess() async -> Bool
}

public final class LocationPermissionService: NSObject, LocationPermissionServicing, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((Bool) -> Void)?

    public override init() {
        super.init()
        manager.delegate = self
    }

    public func status() -> LocationPermissionStatus {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: return .authorized
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    public func requestAccess() async -> Bool {
        let currentStatus = manager.authorizationStatus
        if currentStatus != .notDetermined {
            return currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways
        }

        return await withCheckedContinuation { continuation in
            self.completion = { granted in
                continuation.resume(returning: granted)
            }
            manager.requestWhenInUseAuthorization()
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let s = manager.authorizationStatus
        if s != .notDetermined {
            completion?(s == .authorizedWhenInUse || s == .authorizedAlways)
            completion = nil
        }
    }
}
