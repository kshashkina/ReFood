import Foundation
import AVFoundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {

    @Published var scannedCode: String? = nil
    @Published var isTorchEnabled: Bool = false
    @Published var isScanning: Bool = false
    @Published var product: Product? = nil
    @Published var isLoadingProduct: Bool = false
    @Published var productErrorMessage: String? = nil
    private let scanner: BarcodeScanning
    private let productRepository: ProductRepository

    init(
        scanner: BarcodeScanning = BarcodeScannerService(),
        productRepository: ProductRepository = ProductRepositoryImpl()
    ) {
        self.scanner = scanner
        self.productRepository = productRepository
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

    func scanAgain() {
        product = nil
        productErrorMessage = nil
        scannedCode = nil
        scanner.reset()
        startScanning()
    }
    
    func toggleTorch() {
        isTorchEnabled.toggle()
        scanner.setTorch(enabled: isTorchEnabled)
    }

    private func bindScanner() {
        scanner.onCodeScanned = { [weak self] code in
            guard let self else { return }
            self.scannedCode = code
            self.stopScanning()
            Task {
                await self.loadProduct(barcode: code)
            }
        }
    }

    private func loadProduct(barcode: String) async {
        isLoadingProduct = true
        productErrorMessage = nil
        product = nil

        do {
            let product = try await productRepository.getProduct(byBarcode: barcode)
            self.product = product

        } catch let error as ProductError {
            switch error {
            case .notFound:
                productErrorMessage = "Product not found"
                isScanning = false
            case .invalidData:
                productErrorMessage = "Invalid product data"
                isScanning = false
            case .network:
                productErrorMessage = "Network error"
                isScanning = false
            case .unknown:
                productErrorMessage = "Unknown error"
                isScanning = false
            }

        } catch {
            productErrorMessage = "Unknown error"
        }

        isLoadingProduct = false
    }

    var session: AVCaptureSession {
        scanner.session
    }
}
