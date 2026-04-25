import SwiftUI

struct ScannerScreen: View {
    let onClose: () -> Void
    let onManualInput: () -> Void

    @StateObject private var vm = ScannerViewModel()
    @State private var showManualInput = false
    @State private var previewProduct: Product? = nil
    @State private var detailsProduct: Product? = nil
    @State private var comparisonProduct: Product? = nil
    @State private var showAddProduct: Bool = false

    var body: some View {
        ZStack {
            ScannerView(
                session: vm.session,
                onClose: { vm.onDisappear(); onClose() },
                onTapTorch: { _ in vm.toggleTorch() },
                onTapManualInput: { showManualInput = true },
                onTapScan: { vm.startScanning() }
            )
        }
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        
        .fullScreenCover(isPresented: $showManualInput) {
            ManualInputScreen( onBack: {
                showManualInput = false
                vm.startScanning()
            })
            .onAppear {
                vm.stopScanning()
            }
        }
        
        .sheet(isPresented: $vm.isLoadingProduct) {
            ProductLoadingSheet(
                isPresented: $vm.isLoadingProduct,
                progress: vm.loadingProgress,
                currentStep: vm.currentLoadingStep,
                isFailed: vm.isProductLoadingFailed,
                onFinish: {
                    vm.isLoadingProduct = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        if let fetched = vm.product { previewProduct = fetched }
                    }
                },
                onTryAgain: {
                    vm.isLoadingProduct = false
                    vm.scanAgain()
                },
                onAddProduct: {
                    vm.isLoadingProduct = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showAddProduct = true
                    }
                }
            )
            .presentationDetents([.height(560)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(vm.loadingProgress < 1.0 && !vm.isProductLoadingFailed)
            .onDisappear {
                if previewProduct == nil && detailsProduct == nil && comparisonProduct == nil && !showAddProduct {
                    vm.scanAgain()
                }
            }
        }
        .fullScreenCover(item: $previewProduct) { productB in
            ProductPreviewScreen(
                product: productB,
                firstProductForComparison: vm.firstProductForComparison,
                onBack: { previewProduct = nil; vm.scanAgain() },
                onContinue: {
                    previewProduct = nil
                    if vm.firstProductForComparison != nil {
                        comparisonProduct = productB
                    } else {
                        detailsProduct = productB
                    }
                },
                onScanAgain: { previewProduct = nil; vm.scanAgain() }
            )
        }
        .fullScreenCover(item: $detailsProduct) { product in
            ProductDetailsScreen(
                product: product,
                onBack: {
                    detailsProduct = nil
                    vm.scanAgain()
                },
                onCompare: { productA in
                    detailsProduct = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        vm.setupComparison(with: productA)
                    }
                }
            )
        }
        .fullScreenCover(item: $comparisonProduct) { productB in
            if let productA = vm.firstProductForComparison {
                ProductComparisonScreen(
                    productA: productA,
                    productB: productB,
                    onBack: {
                        comparisonProduct = nil
                        vm.firstProductForComparison = nil
                        vm.scanAgain()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showAddProduct, onDismiss: {vm.scanAgain()}) {
            let repository = ProductRepositoryImpl()
            AddProductScreen(barcode: vm.lastScannedBarcode, repository: repository)
        }
    }
}
