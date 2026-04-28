import Foundation
import AVFoundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var scannedCode: String? = nil
    @Published var lastScannedBarcode: String = ""
    @Published var isTorchEnabled: Bool = false
    @Published var isScanning: Bool = false
    @Published var product: Product? = nil
    @Published var isLoadingProduct: Bool = false
    @Published var isProductLoadingFailed: Bool = false
    @Published var productErrorMessage: String? = nil
    @Published var firstProductForComparison: Product? = nil
    @Published var showNoInternet: Bool = false
    
    @Published var loadingProgress: Double = 0.0
    @Published var currentLoadingStep: ProductLoadingSheet.LoadingStep = .searching
    private var loadingTimer: Timer?

    private let scanner: BarcodeScanning
    private let productRepository: ProductRepository

    init(scanner: BarcodeScanning, productRepository: ProductRepository) {
        self.scanner = scanner
        self.productRepository = productRepository
        bindScanner()
        scanner.configure()
    }

    func setupComparison(with firstProduct: Product) {
        self.firstProductForComparison = firstProduct
        scanAgain()
    }

    func onAppear() { startScanning() }
    func onDisappear() { stopScanning(); stopLoadingAnimation() }

    func startScanning() { scanner.start(); isScanning = true }
    func stopScanning() { scanner.stop(); isScanning = false; isTorchEnabled = false; scanner.setTorch(enabled: false) }

    func scanAgain() {
        product = nil
        isProductLoadingFailed = false
        productErrorMessage = nil
        scannedCode = nil
        loadingProgress = 0.0
        currentLoadingStep = .searching
        showNoInternet = false
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
            self.lastScannedBarcode = code
            self.stopScanning()
            Task { await self.loadProduct(barcode: code) }
        }
    }

    func startLoadingAnimation() {
        stopLoadingAnimation()
        loadingProgress = 0.0
        isProductLoadingFailed = false
        currentLoadingStep = .searching
        
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.loadingProgress < 0.9 {
                    let remainingToTarget = 0.9 - self.loadingProgress
                    let step = max(0.0004, remainingToTarget * 0.008)
                    self.loadingProgress += step
                    
                    if self.loadingProgress > 0.60 && self.currentLoadingStep == .searching {
                        self.currentLoadingStep = .processing
                    }
                }
            }
        }
    }

    func finishLoadingSuccess() {
        stopLoadingAnimation()
        loadingProgress = 1.0
        currentLoadingStep = .ready
    }

    func finishLoadingFailure() {
        stopLoadingAnimation()
        isProductLoadingFailed = true
        loadingProgress = 0.35
    }

    func stopLoadingAnimation() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }

    func loadProduct(barcode: String) async {
        let isConnected = await NetworkMonitor.shared.waitForConnectionStatus()
        
        guard isConnected else {
            stopLoadingAnimation()
            isLoadingProduct = false
            isProductLoadingFailed = false
            productErrorMessage = nil
            showNoInternet = true
            return
        }
        
        isLoadingProduct = true
        productErrorMessage = nil
        isProductLoadingFailed = false
        
        startLoadingAnimation()

        do {
            let fetchedProduct = try await productRepository.getProduct(byBarcode: barcode)
            
            if let urlString = fetchedProduct.imageUrl, let url = URL(string: urlString) {
                Task {
                    try? await ImageLoader.shared.load(url: url)
                }
            }
            
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            self.product = fetchedProduct
            finishLoadingSuccess()
        } catch let error as ProductError {
            if error == .notFound {
                finishLoadingFailure()
            } else if error == .network {
                stopLoadingAnimation()
                isLoadingProduct = false
                isProductLoadingFailed = false
                productErrorMessage = nil
                showNoInternet = true
            } else {
                stopLoadingAnimation()
                isLoadingProduct = false
                productErrorMessage = error.localizedDescription
            }
        } catch {
            stopLoadingAnimation()
            isLoadingProduct = false
            isProductLoadingFailed = false
            productErrorMessage = nil
            showNoInternet = true
        }
    }

    var session: AVCaptureSession { scanner.session }
}
