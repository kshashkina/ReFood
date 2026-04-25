import SwiftUI
import Combine

@MainActor
final class ManualInputViewModel: ObservableObject {
    @Published var barcode: String = ""
    @Published var isLoading = false
    @Published var product: Product? = nil
    @Published var error: String? = nil
    
    @Published var loadingProgress: Double = 0.0
    @Published var currentStep: ProductLoadingSheet.LoadingStep = .searching
    @Published var isFailed = false
    
    private let repository: ProductRepository
    private var loadingTimer: Timer?
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    var isInputValid: Bool {
        let count = barcode.trimmingCharacters(in: .whitespaces).count
        return count >= 7 && count <= 14 && !isLoading
    }
    
    func findProduct() async {
        guard isInputValid else { return }
        
        setupInitialLoadingState()
        startLoadingAnimation()
        
        do {
            let fetchedProduct = try await repository.getProduct(byBarcode: barcode)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.product = fetchedProduct
            finishLoadingSuccess()
        } catch {
            finishLoadingFailure(error)
        }
    }
    
    private func startLoadingAnimation() {
        stopLoadingAnimation()
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.loadingProgress < 0.9 {
                    let remainingToTarget = 0.9 - self.loadingProgress
                    let step = max(0.0004, remainingToTarget * 0.008)
                    self.loadingProgress += step
                    
                    if self.loadingProgress > 0.60 && self.currentStep == .searching {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.currentStep = .processing
                        }
                    }
                }
            }
        }
    }
    
    private func finishLoadingSuccess() {
        stopLoadingAnimation()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            self.loadingProgress = 1.0
            self.currentStep = .ready
        }
    }
    
    private func finishLoadingFailure(_ error: Error) {
        stopLoadingAnimation()
        withAnimation(.spring()) {
            self.isFailed = true
            self.error = error.localizedDescription
            self.loadingProgress = 0.35
        }
    }
    
    private func stopLoadingAnimation() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }
    
    private func setupInitialLoadingState() {
        isLoading = true
        isFailed = false
        error = nil
        loadingProgress = 0.0
        currentStep = .searching
    }
    
    deinit {
        loadingTimer?.invalidate()
    }
}
