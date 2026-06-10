import SwiftUI

struct RootView: View {

    private enum Step {
        case splash
        case onboarding
        case main
    }

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    @State private var step: Step = .splash
    @State private var dashboardData: DailyDashboardResponse? = nil
    @State private var isPreparingApp: Bool = false
    @State private var showPreparingLoader: Bool = false
    
    private let analytics: AnalyticsServiceProtocol = AmplitudeAnalyticsService.shared

    var body: some View {
        ZStack {
            if step == .main {
                let authRepo = AmplifyAuthRepository()
                let userRepo = UserRepositoryImpl()
                let localStorage = UserDefaultsLocalStorage()
                let deviceProvider = KeychainDeviceIDManager()
                
                let dbCleaner = SwiftDataCleaner()
                let historyRepo = HistoryRepositoryImpl()
                let productRepo = ProductRepositoryImpl()
                let syncUseCase = SyncUserDataUseCase(
                    historyRepository: historyRepo,
                    productRepository: productRepo
                )
                
                let linkUseCase = LinkAppleAccountUseCase(
                    authRepository: authRepo,
                    userRepository: userRepo,
                    localStorage: localStorage,
                    deviceIDProvider: deviceProvider,
                    syncUseCase: syncUseCase
                )
                
                let deleteUseCase = DeleteAccountUseCase(
                    authRepository: authRepo,
                    userRepository: userRepo,
                    localStorage: localStorage,
                    deviceIDProvider: deviceProvider,
                    databaseCleaner: dbCleaner,
                    analytics: analytics
                )

                MainContainerView(
                    dashboardData: dashboardData,
                    localStorage: localStorage,
                    linkUseCase: linkUseCase,
                    deleteUseCase: deleteUseCase
                )
                .transition(.opacity)
            }

            if step == .onboarding {
                OnboardingFlowView(analytics: analytics) {
                    hasSeenOnboarding = true
                    withAnimation(.easeInOut(duration: 0.35)) {
                        step = .main
                    }
                }
                .transition(.opacity)
            }

            if step == .splash {
                SplashView(
                    repository: DashboardRepositoryImpl(),
                    showPreparingLoader: showPreparingLoader
                ) { fetchedData in
                    Task {
                        await prepareAppAndContinue(with: fetchedData)
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            analytics.track(OnboardingEvent.appLaunch)
        }
        .onChange(of: hasSeenOnboarding) { newValue in
            if newValue == false {
                withAnimation(.easeInOut(duration: 0.5)) {
                    step = .splash
                    self.dashboardData = nil
                    self.showPreparingLoader = false
                }
            }
        }
    }
    
    @MainActor
    private func prepareAppAndContinue(with fetchedData: DailyDashboardResponse?) async {
        guard !isPreparingApp else { return }
        isPreparingApp = true
        
        self.dashboardData = fetchedData
        
        let authRepo = AmplifyAuthRepository()
        let userRepo = UserRepositoryImpl()
        let localStorage = UserDefaultsLocalStorage()
        let deviceProvider = KeychainDeviceIDManager()
        
        await authRepo.repairExpiredSessionIfNeeded()
        
        let registrationUseCase = RegisterAnonymousUserUseCase(
            authRepository: authRepo,
            userRepository: userRepo,
            localStorage: localStorage,
            deviceIDProvider: deviceProvider,
            analytics: analytics
        )
        
        let registrationResult = await registrationUseCase.execute()
        
        if registrationResult == .reinstall {
            withAnimation(.easeInOut(duration: 0.25)) {
                showPreparingLoader = true
            }
            
            let historyRepo = HistoryRepositoryImpl()
            let productRepo = ProductRepositoryImpl()
            let syncUseCase = SyncUserDataUseCase(
                historyRepository: historyRepo,
                productRepository: productRepo
            )
            
            await syncUseCase.execute()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                showPreparingLoader = false
            }
        }
        
        isPreparingApp = false
        
        withAnimation(.easeInOut(duration: 0.35)) {
            if hasSeenOnboarding {
                step = .main
            } else {
                step = .onboarding
            }
        }
    }
}
