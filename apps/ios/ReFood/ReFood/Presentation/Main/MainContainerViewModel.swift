import Foundation
import Combine
import UIKit

final class MainContainerViewModel: ObservableObject {

    @Published var isCameraAccessModalPresented: Bool = false
    @Published var isScannerPresented: Bool = false

    private let cameraPermissionService: CameraPermissionServicing

    init(cameraPermissionService: CameraPermissionServicing = CameraPermissionService()) {
        self.cameraPermissionService = cameraPermissionService
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
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
