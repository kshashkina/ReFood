import SwiftUI

struct MainContainerView: View {
    let dashboardData: DailyDashboardResponse?
    @State private var selectedTab: MainTab = .home
    @StateObject private var vm = MainContainerViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var mapFilter: String = "filter_all"

    private let languageProvider = SystemLanguageProvider()
    private let metricsRepo = UserDefaultsMetricsRepository()
    private let historyRepo = HistoryRepositoryImpl()
    private let productRepo: ProductRepositoryImpl
    private let uploadService: ImageUploadService
    private let aiRepo = AIComparisonRepositoryImpl()
    private let locationRepo = LocationRepositoryImpl()
    private let locationService = LocationService()
    private let emailService = URLEmailService()
    
    private let localStorage: LocalStorageProtocol
    private let linkUseCase: LinkAppleAccountUseCase
    private let deleteUseCase: DeleteAccountUseCase
    
    private let analytics: AnalyticsServiceProtocol = AmplitudeAnalyticsService.shared

    init(
        dashboardData: DailyDashboardResponse?,
        localStorage: LocalStorageProtocol,
        linkUseCase: LinkAppleAccountUseCase,
        deleteUseCase: DeleteAccountUseCase
    ) {
        self.dashboardData = dashboardData
        self.localStorage = localStorage
        self.linkUseCase = linkUseCase
        self.deleteUseCase = deleteUseCase
        
        let pRepo = ProductRepositoryImpl()
        self.productRepo = pRepo
        self.uploadService = ImageUploadService(repository: pRepo)
    }

    var body: some View {
        ZStack {
            content
                .ignoresSafeArea()

            VStack {
                Spacer()
                MainTabBar(
                    analytics: analytics,
                    onTapScanner: { vm.onTapScan()},
                    selected: $selectedTab
                )
                .padding(.bottom, 16)
            }.ignoresSafeArea(.keyboard, edges: .bottom)

            if vm.isCameraAccessModalPresented {
                CameraAccessModalView(
                    isPresented: $vm.isCameraAccessModalPresented,
                    onOpenSettings: { vm.openAppSettings() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
            
            if vm.isLocationAccessModalPresented {
                LocationAccessModalView(
                    isPresented: $vm.isLocationAccessModalPresented,
                    onOpenSettings: {
                        analytics.track(MapEvent.locationDeniedSettingsTap)
                        vm.openAppSettings()
                    }
                )
                .onAppear {
                    analytics.track(MapEvent.locationDeniedModalView)
                }
                .transition(.opacity)
                .zIndex(101)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isCameraAccessModalPresented)
        .animation(.easeInOut(duration: 0.2), value: vm.isLocationAccessModalPresented)
        .onChange(of: vm.isLocationAccessModalPresented) { isPresented in
            if !isPresented {
                analytics.track(MapEvent.locationDeniedCloseTap)
            }
        }
        
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                vm.refreshStatuses()
                metricsRepo.updateStreak()
            }
        }
        .onChange(of: vm.isScannerPresented) { isPresented in
            if isPresented {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedTab = .home
                }
            }
        }
        .fullScreenCover(isPresented: $vm.isScannerPresented) {
            ScannerScreen(
                repository: productRepo,
                uploadService: uploadService,
                aiRepository: aiRepo,
                languageProvider: languageProvider,
                historyRepository: historyRepo,
                metricsRepository: metricsRepo,
                onClose: { vm.isScannerPresented = false },
                onFindRecyclingPoint: { selectedFilter in
                    vm.isScannerPresented = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.mapFilter = selectedFilter
                        self.selectedTab = .map
                    }
                }
            )
        }
        .fullScreenCover(item: $vm.selectedSearchProduct) { product in
            ProductDetailsScreen(
                product: product,
                repository: productRepo,
                uploadService: uploadService,
                languageProvider: languageProvider,
                metricsRepository: metricsRepo,
                onBack: {
                    vm.selectedSearchProduct = nil
                },
                onFindRecyclingPoint: { selectedFilter in
                    vm.selectedSearchProduct = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.mapFilter = selectedFilter
                        self.selectedTab = .map
                    }
                }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home:
            HomeView(
                dashboardData: dashboardData,
                languageProvider: languageProvider,
                metricsRepository: metricsRepo,
                analytics: analytics,
                onProductTap: { product in
                    vm.selectedSearchProduct = product
                },
                onSeeAllTap: {
                    selectedTab = .search
                }
            )
        case .search:
            SearchView(
                historyRepository: historyRepo,
                analytics: analytics,
                onProductTap: { product in
                    vm.selectedSearchProduct = product
                }
            )
        case .map:
            let showWarning = vm.locationPermissionStatus == .denied || vm.locationPermissionStatus == .restricted

            MapView(
                repository: locationRepo,
                networkMonitor: NetworkMonitor.shared,
                locationService: locationService,
                showLocationWarning: showWarning,
                externalFilter: $mapFilter,
                analytics: analytics,
                onRequestLocationAccess: {
                    vm.isLocationAccessModalPresented = true
                }
            )
            .onAppear { vm.requestLocationIfNeeded()
                metricsRepo.trackMapCheck()}
        case .profile: ProfileView(
                    metricsRepository: metricsRepo,
                    emailService: emailService,
                    linkAccountUseCase: linkUseCase,
                    deleteAccountUseCase: deleteUseCase,
                    localStorage: localStorage,
                    analytics: analytics
                )
        }
    }
}
