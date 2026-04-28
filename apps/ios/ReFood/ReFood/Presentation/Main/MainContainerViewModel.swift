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

    private var hasShownLocationAlert: Bool = false
    private let cameraPermissionService: CameraPermissionServicing
    private let locationPermissionService: LocationPermissionServicing

    init(
        cameraPermissionService: CameraPermissionServicing = CameraPermissionService(),
        locationPermissionService: LocationPermissionServicing = LocationPermissionService()
    ) {
        self.cameraPermissionService = cameraPermissionService
        self.locationPermissionService = locationPermissionService
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
                let granted = await cameraPermissionService.requestAccess()
                if granted {
                    isScannerPresented = true
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
                let granted = await locationPermissionService.requestAccess()
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
