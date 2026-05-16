import SwiftUI

struct MainContainerView: View {
    @State private var selectedTab: MainTab = .home
    @StateObject private var vm = MainContainerViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var mapFilter: String = "filter_all"

    var body: some View {
        ZStack {
            content
                .ignoresSafeArea()

            VStack {
                Spacer()
                MainTabBar(
                    onTapScanner: { vm.onTapScan()}, selected: $selectedTab
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
                    onOpenSettings: { vm.openAppSettings() }
                )
                .transition(.opacity)
                .zIndex(101)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isCameraAccessModalPresented)
        .animation(.easeInOut(duration: 0.2), value: vm.isLocationAccessModalPresented)
        
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                vm.refreshStatuses()
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
            let repository = ProductRepositoryImpl()
            ScannerScreen(
                repository: repository,
                uploadService: ImageUploadService(repository: repository),
                aiRepository: AIComparisonRepositoryImpl(),
                languageProvider: SystemLanguageProvider(),
                historyRepository: HistoryRepositoryImpl(),
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
            let repository = ProductRepositoryImpl()
            ProductDetailsScreen(
                product: product,
                repository: repository,
                uploadService: ImageUploadService(repository: repository),
                languageProvider: SystemLanguageProvider(),
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
        case .home: HomeView()
        case .search:
            let historyRepo = HistoryRepositoryImpl()            
            SearchView(
                historyRepository: historyRepo,
                onProductTap: { product in
                    vm.selectedSearchProduct = product
                }
            )
        case .map:
            let showWarning = vm.locationPermissionStatus == .denied || vm.locationPermissionStatus == .restricted

            MapView(
                repository: LocationRepositoryImpl(),
                networkMonitor: NetworkMonitor.shared,
                locationService: LocationService(),
                showLocationWarning: showWarning,
                externalFilter: $mapFilter,
                onRequestLocationAccess: {
                    vm.isLocationAccessModalPresented = true
                }
            )
            .onAppear { vm.requestLocationIfNeeded() }
        case .profile: ProfileView()
        }
    }
}
