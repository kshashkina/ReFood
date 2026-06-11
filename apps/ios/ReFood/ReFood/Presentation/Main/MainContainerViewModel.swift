import Foundation
import Combine
import UIKit

final class MainContainerViewModel: ObservableObject {

    @Published var isCameraAccessModalPresented: Bool = false
    @Published var isLocationAccessModalPresented: Bool = false
    @Published var isScannerPresented: Bool = false
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    @Published var selectedTab: MainTab = .home
    @Published var selectedMapFilter: String = "All"
    @Published var selectedSearchProduct: Product? = nil
    @Published var productToCompare: Product? = nil

    private var hasShownLocationAlert: Bool = false
    private let cameraPermissionService: CameraPermissionServicing
    private let locationPermissionService: LocationPermissionServicing
    
    private let analytics: AnalyticsServiceProtocol

    init(
        cameraPermissionService: CameraPermissionServicing = CameraPermissionService(),
        locationPermissionService: LocationPermissionServicing = LocationPermissionService(),
        analytics: AnalyticsServiceProtocol = AmplitudeAnalyticsService.shared
    ) {
        self.cameraPermissionService = cameraPermissionService
        self.locationPermissionService = locationPermissionService
        self.analytics = analytics
        refreshStatuses()
    }

    @MainActor
    func refreshStatuses() {
        let newStatus = locationPermissionService.status()
        self.locationPermissionStatus = newStatus
        if newStatus == .authorized {
            isLocationAccessModalPresented = false
        }
        if cameraPermissionService.status() == .authorized {
            isCameraAccessModalPresented = false
        }
    }

    @MainActor
    func onTapScan() {
        switch cameraPermissionService.status() {
        case .authorized:
            isScannerPresented = true

        case .notDetermined:
            Task { @MainActor in
                analytics.track(ScannerEvent.cameraAccessModalView)
                let granted = await cameraPermissionService.requestAccess()
                if granted {
                    analytics.track(ScannerEvent.cameraAccessAllow)
                    isScannerPresented = true
                } else {
                    analytics.track(ScannerEvent.cameraAccessDeny)
                }
            }

        case .denied, .restricted:
            isCameraAccessModalPresented = true
        }
    }

    @MainActor
    func requestLocationIfNeeded() {
        refreshStatuses()

        switch locationPermissionStatus {
        case .authorized:
            break
        case .notDetermined:
            Task { @MainActor in
                analytics.track(MapEvent.locationModalView)
                let granted = await locationPermissionService.requestAccess()
                if granted {
                    analytics.track(MapEvent.locationAccessAllow)
                } else {
                    analytics.track(MapEvent.locationAccessDeny)
                }
                refreshStatuses()
                if !granted && !hasShownLocationAlert {
                    isLocationAccessModalPresented = true
                    hasShownLocationAlert = true
                }
            }
        case .denied, .restricted:
            if !hasShownLocationAlert {
                isLocationAccessModalPresented = true
                hasShownLocationAlert = true
            }
        }
    }

    @MainActor
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
