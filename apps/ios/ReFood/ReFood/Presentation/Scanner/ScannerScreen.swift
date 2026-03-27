import SwiftUI

struct ScannerScreen: View {
    let onClose: () -> Void
    let onManualInput: () -> Void

    @StateObject private var vm = ScannerViewModel()
    @State private var previewProduct: Product? = nil
    @State private var detailsProduct: Product? = nil

    var body: some View {
        ZStack {
            ScannerView(
                session: vm.session,
                onClose: { vm.onDisappear(); onClose() },
                onTapTorch: { _ in vm.toggleTorch() },
                onTapManualInput: { vm.onDisappear(); onManualInput() },
                onTapScan: { vm.startScanning() }
            )
        }
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        
        .sheet(isPresented: $vm.isLoadingProduct) {
            ProductLoadingSheet(
                isPresented: $vm.isLoadingProduct,
                progress: vm.loadingProgress,
                currentStep: vm.currentLoadingStep,
                isFailed: vm.isProductLoadingFailed,
                onFinish: {
                    vm.isLoadingProduct = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        if let product = vm.product { previewProduct = product }
                    }
                },
                onTryAgain: {
                    vm.isLoadingProduct = false
                    vm.scanAgain()
                },
                onAddProduct: {
                    // тут потім додати на ед продакт екран
                }
            )
            .presentationDetents([.height(560)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(vm.loadingProgress < 1.0 && !vm.isProductLoadingFailed)
            .onDisappear {
                if previewProduct == nil && detailsProduct == nil {
                    vm.scanAgain()
                }
            }
        }
        .fullScreenCover(item: $previewProduct) { product in
            ProductPreviewScreen(
                product: product,
                onBack: { previewProduct = nil; vm.scanAgain() },
                onContinue: { previewProduct = nil; detailsProduct = product },
                onScanAgain: { previewProduct = nil; vm.scanAgain() }
            )
        }
        .fullScreenCover(item: $detailsProduct) { product in
            ProductDetailsScreen(
                product: product,
                onBack: { detailsProduct = nil; vm.scanAgain() }
            )
        }
    }
}
