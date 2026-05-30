import SwiftUI

struct ManualInputScreen: View {
    @StateObject private var vm: ManualInputViewModel
    @State private var path: [Destination] = []
    private let repository: ProductRepository
    private let uploadService: ImageUploadServicing
    private let aiRepository: AIComparisonRepository
    private let languageProvider: LanguageProvider
    private let metricsRepository: MetricsRepositoryProtocol
    let analytics: AnalyticsServiceProtocol
    
    let firstProductForComparison: Product?
    let onClose: () -> Void
    let onResetScanner: () -> Void
    let onCompareFromDetails: (Product) -> Void
    let onFindRecyclingPoint: (String) -> Void

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
        historyRepository: HistoryRepository,
        metricsRepository: MetricsRepositoryProtocol,
        firstProductForComparison: Product? = nil,
        analytics: AnalyticsServiceProtocol,
        onClose: @escaping () -> Void,
        onResetScanner: @escaping () -> Void,
        onCompareFromDetails: @escaping (Product) -> Void,
        onFindRecyclingPoint: @escaping (String) -> Void
    ) {
        self._vm = StateObject(wrappedValue: ManualInputViewModel(
            repository: repository,
            historyRepository: historyRepository,
            metricsRepository: metricsRepository
        ))
        
        self.repository = repository
        self.uploadService = uploadService
        self.aiRepository = aiRepository
        self.languageProvider = languageProvider
        self.metricsRepository = metricsRepository
        self.firstProductForComparison = firstProductForComparison
        self.analytics = analytics
        self.onClose = onClose
        self.onResetScanner = onResetScanner
        self.onCompareFromDetails = onCompareFromDetails
        self.onFindRecyclingPoint = onFindRecyclingPoint
    }

    var body: some View {
        NavigationStack(path: $path) {
            ManualInputView(
                vm: vm,
                analytics: analytics,
                onClose: onClose,
                onFind: {
                    Task { await vm.findProduct() }
                }
            )
            .onAppear {
                analytics.track(ManualInputEvent.screenView)
            }
            .toolbar(.hidden)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .preview(let product):
                    ProductPreviewScreen(
                        product: product,
                        firstProductForComparison: firstProductForComparison,
                        languageProvider: languageProvider,
                        analytics: analytics,
                        onBack: { onResetScanner() },
                        onContinue: {
                            if let first = firstProductForComparison {
                                path.append(.comparison(first, product))
                            } else {
                                path.append(.details(product))
                            }
                        },
                        onScanAgain: { onResetScanner() }
                    )
                    .toolbar(.hidden)
                    
                case .details(let product):
                    ProductDetailsScreen(
                        product: product,
                        repository: repository,
                        uploadService: uploadService,
                        languageProvider: languageProvider,
                        metricsRepository: metricsRepository,
                        analytics: analytics,
                        onBack: { onResetScanner() },
                        onCompare: { pA in onCompareFromDetails(pA) },
                        onFindRecyclingPoint: { filter in onFindRecyclingPoint(filter) }
                    )
                    .toolbar(.hidden)
                    
                case .comparison(let pA, let pB):
                    ProductComparisonScreen(
                        productA: pA,
                        productB: pB,
                        aiRepository: aiRepository,
                        languageProvider: languageProvider,
                        analytics: analytics,
                        onBack: { onResetScanner() }
                    )
                    .toolbar(.hidden)
                    
                case .addProduct(let barcode):
                    AddProductScreen(
                        barcode: barcode,
                        repository: repository,
                        uploadService: uploadService,
                        metricsRepository: metricsRepository
                    )
                    .toolbar(.hidden)
                }
            }
            .sheet(isPresented: $vm.isLoading, onDismiss: {
                if path.isEmpty {
                    if vm.isFailed {
                        analytics.track(LoadingSheetEvent.notFoundSwipe)
                    } else {
                        let step = vm.loadingProgress >= 1.0 ? "ready" : "loading"
                        analytics.track(LoadingSheetEvent.productLoadingSwipe(step: step))
                    }
                }
                vm.isLoading = false
            }) {
                ProductLoadingSheet(
                    isPresented: $vm.isLoading,
                    progress: vm.loadingProgress,
                    currentStep: vm.currentStep,
                    isFailed: vm.isFailed,
                    onFinish: {
                        analytics.track(LoadingSheetEvent.productLoadingContinueTap)
                        vm.isLoading = false
                        if let p = vm.product {
                            path.append(.preview(p))
                        }
                    },
                    onTryAgain: {
                        analytics.track(LoadingSheetEvent.notFoundTryAgainTap)
                        vm.isLoading = false
                    },
                    onAddProduct: {
                        analytics.track(LoadingSheetEvent.notFoundAddTap)
                        vm.isLoading = false
                        path.append(.addProduct(vm.barcode))
                    }
                )
                .onAppear {
                    analytics.track(LoadingSheetEvent.productLoadingModalView)
                }
                .onChange(of: vm.isFailed) { isFailed in
                    if isFailed {
                        analytics.track(LoadingSheetEvent.notFoundModalView)
                    }
                }
                .presentationDetents([.height(560)])
            }
            .sheet(isPresented: $vm.showNoInternet, onDismiss: {
                vm.resetAfterNoInternet()
            }) {
                NoInternetSheet {
                    analytics.track(NoInternetEvent.noInternetOkTap)
                    vm.showNoInternet = false
                }
                .onAppear {
                    analytics.track(NoInternetEvent.noInternetModalView)
                }
                .presentationDetents([.height(360)])
            }
        }
    }
}
