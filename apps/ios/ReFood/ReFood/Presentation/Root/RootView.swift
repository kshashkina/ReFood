import SwiftUI

struct RootView: View {
    @ObservedObject var container: AppDIContainer

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
    
    var body: some View {
        ZStack {
            if step == .main {
                let mainViewModel = MainContainerViewModel(
                    cameraPermissionService: container.cameraPermissionService,
                    locationPermissionService: container.locationPermissionService,
                    analytics: container.analytics
                )

                MainContainerView(
                    dashboardData: dashboardData,
                    viewModel: mainViewModel,
                    languageProvider: container.languageProvider,
                    metricsRepo: container.metricsRepo,
                    historyRepo: container.historyRepo,
                    productRepo: container.productRepo,
                    uploadService: container.uploadService,
                    aiRepo: container.aiRepo,
                    locationRepo: container.locationRepo,
                    locationService: container.locationService,
                    emailService: container.emailService,
                    localStorage: container.localStorage,
                    linkUseCase: container.linkUseCase,
                    deleteUseCase: container.deleteUseCase,
                    analytics: container.analytics
                )
                .transition(.opacity)
            }

            if step == .onboarding {
                OnboardingFlowView(analytics: container.analytics) {
                    hasSeenOnboarding = true
                    withAnimation(.easeInOut(duration: 0.35)) {
                        step = .main
                    }
                }
                .transition(.opacity)
            }

            if step == .splash {
                SplashView(
                    repository: container.dashboardRepo,
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
            container.analytics.track(OnboardingEvent.appLaunch)
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
        
        await container.authRepo.repairExpiredSessionIfNeeded()
        
        let registrationResult = await container.registerUseCase.execute()
        
        if registrationResult == .reinstall {
            withAnimation(.easeInOut(duration: 0.25)) {
                showPreparingLoader = true
            }
            
            await container.syncUseCase.execute()
            
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
