import SwiftUI

struct ScannerScreen: View {
    let onClose: () -> Void
    @StateObject private var vm = ScannerViewModel()
    @State private var showManualInput = false
    
    @State private var path: [Destination] = []

    enum Destination: Hashable {
        case preview(Product)
        case details(Product)
        case comparison(Product, Product)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ScannerView(
                    session: vm.session,
                    onClose: {
                        vm.onDisappear()
                        onClose()
                    },
                    onTapTorch: { _ in vm.toggleTorch() },
                    onTapManualInput: {
                        showManualInput = true
                    },
                    onTapScan: {
                        vm.startScanning()
                    }
                )
            }
            .onAppear {
                vm.onAppear()
            }
            .onDisappear {
                vm.onDisappear()
            }
            .toolbar(.hidden)
            
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .preview(let product):
                    ProductPreviewScreen(
                        product: product,
                        firstProductForComparison: vm.firstProductForComparison,
                        onBack: {
                            path.removeAll()
                            vm.firstProductForComparison = nil
                            vm.scanAgain()
                        },
                        onContinue: {
                            if let first = vm.firstProductForComparison {
                                path.append(.comparison(first, product))
                            } else {
                                path.append(.details(product))
                            }
                        },
                        onScanAgain: {
                            path.removeAll()
                            vm.firstProductForComparison = nil
                            vm.scanAgain()
                        }
                    )
                    .toolbar(.hidden)
                    
                case .details(let product):
                    ProductDetailsScreen(
                        product: product,
                        onBack: {
                            path.removeAll()
                            vm.firstProductForComparison = nil
                            vm.scanAgain()
                        },
                        onCompare: { pA in
                            path.removeAll()
                            vm.setupComparison(with: pA)
                        }
                    )
                    .toolbar(.hidden)
                    
                case .comparison(let pA, let pB):
                    ProductComparisonScreen(
                        productA: pA,
                        productB: pB,
                        onBack: {
                            path.removeAll()
                            vm.firstProductForComparison = nil
                            vm.scanAgain()
                        }
                    )
                    .toolbar(.hidden)
                }
            }
            .fullScreenCover(isPresented: $showManualInput) {
                ManualInputScreen(
                    repository: ProductRepositoryImpl(),
                    firstProductForComparison: vm.firstProductForComparison,
                    onClose: {
                        showManualInput = false
                        vm.scanAgain()
                    },
                    onResetScanner: {
                        showManualInput = false
                        vm.firstProductForComparison = nil
                        vm.scanAgain()
                    },
                    onCompareFromDetails: { pA in
                        showManualInput = false
                        vm.setupComparison(with: pA)
                    }
                )
            }
            .sheet(isPresented: $vm.isLoadingProduct, onDismiss: {
                if path.isEmpty && !showManualInput {
                    vm.scanAgain()
                }
            }) {
                ProductLoadingSheet(
                    isPresented: $vm.isLoadingProduct,
                    progress: vm.loadingProgress,
                    currentStep: vm.currentLoadingStep,
                    onFinish: {
                        vm.isLoadingProduct = false
                        if let fetched = vm.product {
                            path.append(.preview(fetched))
                        }
                    },
                    onTryAgain: {
                        vm.isLoadingProduct = false
                        vm.scanAgain()
                    },
                    onAddProduct: {
                        vm.isLoadingProduct = false
                    }
                )
                .presentationDetents([.height(560)])
            }
        }
    }
}
