import SwiftUI
import AVFoundation

struct ScannerScreen: View {

    let onClose: () -> Void
    let onManualInput: () -> Void

    @StateObject private var vm = ScannerViewModel()

    var body: some View {
        ScannerView(
            session: vm.session,
            onClose: {
                vm.onDisappear()
                onClose()
            },
            onTapTorch: { _ in vm.toggleTorch() },
            onTapManualInput: onManualInput,
            onTapScan: { vm.startScanning() }
        )
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
    }
}
