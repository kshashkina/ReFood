import SwiftUI
import AVFoundation

struct ScannerScreen: View {

    let onClose: () -> Void
    let onManualInput: () -> Void

    @StateObject private var vm = ScannerViewModel()
    @State private var previewProduct: Product? = nil
    @State private var detailsProduct: Product? = nil
    @State private var showNotFoundModal = false

    var body: some View {
        ScannerView(
            session: vm.session,
            isLoading: vm.isLoadingProduct,
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
        .onChange(of: vm.product?.barcode) { _, _ in
            if let product = vm.product {
                previewProduct = product
            }
        }

        .onChange(of: vm.productErrorMessage) { _, msg in
            let isNotFound = (msg == "Product not found")
            if isNotFound {
                previewProduct = nil
                detailsProduct = nil
                showNotFoundModal = true
            } else {
                showNotFoundModal = false
            }
        }

        .fullScreenCover(item: $previewProduct) { product in
            ProductPreviewScreen(
                product: product,
                onBack: {
                    previewProduct = nil
                    vm.scanAgain()
                },
                onContinue: {
                    previewProduct = nil
                    detailsProduct = product
                },
                onScanAgain: {
                    previewProduct = nil
                    vm.scanAgain()
                }
            )
        }
        .fullScreenCover(item: $detailsProduct) { product in
            ProductDetailsScreen(
                product: product,
                onBack: {
                    detailsProduct = nil
                    vm.scanAgain()
                }
            )
        }
        .fullScreenCover(isPresented: $showNotFoundModal) {
            ProductNotFoundModalView(
                isPresented: $showNotFoundModal,
                barcode: vm.scannedCode ?? "",
                onTryAgain: {
                    showNotFoundModal = false
                    vm.scanAgain()
                },
                onAddProduct: {
                },
                onClose: {
                    showNotFoundModal = false
                    vm.scanAgain()
                }
            )
        }
    }
}
