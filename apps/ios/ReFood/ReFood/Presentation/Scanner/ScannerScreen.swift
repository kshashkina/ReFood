import SwiftUI

struct ScannerScreen: View {
    @StateObject private var vm: ScannerViewModel
    let onClose: () -> Void
    
    @State private var showManualInput = false
    @State private var path: [Destination] = []

    private let repository: ProductRepository
    private let uploadService: ImageUploadServicing
    private let aiRepository: AIComparisonRepository
    private let languageProvider: LanguageProvider

    enum Destination: Hashable {
        case preview(Product)
        case details(Product)
        case comparison(Product, Product)
        case addProduct(String)
    }

    init(
        repository: ProductRepository,
        uploadService: ImageUploadServicing,
        aiRepository: AIComparisonRepository,
        languageProvider: LanguageProvider,
        scannerService: BarcodeScanning = BarcodeScannerService(),
        onClose: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: ScannerViewModel(
            scanner: scannerService,
            productRepository: repository
        ))
        self.repository = repository
        self.uploadService = uploadService
        self.aiRepository = aiRepository
        self.languageProvider = languageProvider
        self.onClose = onClose
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
                    isTorchOn: vm.isTorchEnabled,
                    onTapTorch: { vm.toggleTorch() },
                    onTapManualInput: { showManualInput = true },
                    onTapScan: { vm.startScanning() }
                )
            }
            .onAppear { vm.onAppear() }
            .onDisappear { vm.onDisappear() }
            .toolbar(.hidden)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .preview(let product):
                    ProductPreviewScreen(
                        product: product,
                        firstProductForComparison: vm.firstProductForComparison,
                        languageProvider: languageProvider,
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
                        repository: repository,
                        uploadService: uploadService,
                        languageProvider: languageProvider,
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
                        aiRepository: aiRepository,
                        languageProvider: languageProvider,
                        onBack: {
                            path.removeAll()
                            vm.firstProductForComparison = nil
                            vm.scanAgain()
                        }
                    )
                    .toolbar(.hidden)
                    
                case .addProduct(let barcode):
                    AddProductScreen(
                        barcode: barcode,
                        repository: repository,
                        uploadService: uploadService
                    )
                    .toolbar(.hidden)
                }
            }
            .fullScreenCover(isPresented: $showManualInput) {
                ManualInputScreen(
                    repository: repository,
                    uploadService: uploadService,
                    aiRepository: aiRepository,
                    languageProvider: languageProvider,
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
                if path.isEmpty && !showManualInput { vm.scanAgain() }
            }) {
                ProductLoadingSheet(
                    isPresented: $vm.isLoadingProduct,
                    progress: vm.loadingProgress,
                    currentStep: vm.currentLoadingStep,
                    isFailed: vm.isProductLoadingFailed,
                    onFinish: {
                        vm.isLoadingProduct = false
                        if let fetched = vm.product { path.append(.preview(fetched)) }
                    },
                    onTryAgain: {
                        vm.isLoadingProduct = false
                        vm.scanAgain()
                    },
                    onAddProduct: {
                        vm.isLoadingProduct = false
                        path.append(.addProduct(vm.lastScannedBarcode))
                    }
                )
                .presentationDetents([.height(560)])
            }
                .sheet(isPresented: $vm.showNoInternet, onDismiss: {
                    if path.isEmpty && !showManualInput {
                        vm.scanAgain()
                    }
                }) {
                    NoInternetSheet {
                        vm.showNoInternet = false
                    }
                    .presentationDetents([.height(360)])}
        }
    }
}
