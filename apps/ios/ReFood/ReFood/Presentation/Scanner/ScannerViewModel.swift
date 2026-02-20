import Foundation
import AVFoundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {

    @Published var scannedCode: String? = nil
    @Published var isTorchEnabled: Bool = false
    @Published var isScanning: Bool = false

    private let scanner: BarcodeScanning

    init(scanner: BarcodeScanning = BarcodeScannerService()) {
        self.scanner = scanner
        bindScanner()
        scanner.configure()
    }

    func onAppear() {
        startScanning()
    }

    func onDisappear() {
        stopScanning()
    }

    func startScanning() {
        scanner.start()
        isScanning = true
    }

    func stopScanning() {
        scanner.stop()
        isScanning = false
    }

    // func scanAgain() {
       // scannedCode = nil
       // scanner.reset()
        // startScanning()
    // } - по ідеї не потрібне буде, але в дебазі допомогло, то потім приберу якщо не будемо юзати

    func toggleTorch() {
        isTorchEnabled.toggle()
        scanner.setTorch(enabled: isTorchEnabled)
    }

    private func bindScanner() {
        scanner.onCodeScanned = { [weak self] code in
            guard let self else { return }
            self.scannedCode = code
            self.stopScanning()
        }
    }

    var session: AVCaptureSession {
        scanner.session
    }
}
