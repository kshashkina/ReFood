import SwiftUI
import AVFoundation

struct ScannerScreen: View {

    let onClose: () -> Void
    let onManualInput: () -> Void

    @StateObject private var vm = ScannerViewModel()
    @State private var previewProduct: Product? = nil
    @State private var detailsProduct: Product? = nil  

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
    }
}
