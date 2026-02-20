import Foundation
import AVFoundation

public enum CameraPermissionStatus: Equatable {
    case authorized
    case notDetermined
    case denied
    case restricted
}

public protocol CameraPermissionServicing {
    func status() -> CameraPermissionStatus
    func requestAccess() async -> Bool
    func canRequestAgain() -> Bool
}

public final class CameraPermissionService: CameraPermissionServicing {

    public init() {}

    public func status() -> CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    public func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    public func canRequestAgain() -> Bool {
        status() == .notDetermined
    }
}
