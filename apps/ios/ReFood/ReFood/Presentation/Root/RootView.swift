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
    private let analytics: AnalyticsServiceProtocol = AmplitudeAnalyticsService.shared

    var body: some View {
        ZStack {
            if step == .main {
                let authRepo = AmplifyAuthRepository()
                let userRepo = UserRepositoryImpl()
                let localStorage = UserDefaultsLocalStorage()
                let deviceProvider = KeychainDeviceIDManager()
                
                let dbCleaner = SwiftDataCleaner()
                
                let linkUseCase = LinkAppleAccountUseCase(authRepository: authRepo, userRepository: userRepo, localStorage: localStorage, deviceIDProvider: deviceProvider)
                
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
                SplashView(repository: DashboardRepositoryImpl()) { fetchedData in
                    self.dashboardData = fetchedData
                    withAnimation(.easeInOut(duration: 0.35)) {
                        if hasSeenOnboarding {
                            step = .main
                        } else {
                            step = .onboarding
                        }
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
                }
            }
        }
        .task(id: step) {
            if step == .splash {
                let authRepo = AmplifyAuthRepository()
                let userRepo = UserRepositoryImpl()
                let localStorage = UserDefaultsLocalStorage()
                let deviceProvider = KeychainDeviceIDManager()
                
                let registrationUseCase = RegisterAnonymousUserUseCase(
                    authRepository: authRepo,
                    userRepository: userRepo,
                    localStorage: localStorage,
                    deviceIDProvider: deviceProvider,
                    analytics: analytics
                )
                await registrationUseCase.execute()
            }
        }
    }
}
