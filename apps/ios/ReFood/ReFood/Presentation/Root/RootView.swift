import SwiftUI
//import AmplitudeUnified

struct RootView: View {

    private enum Step {
        case splash
        case onboarding
        case paywall
        case main
    }

    @State private var step: Step = .splash
    
    @State private var dashboardData: DailyDashboardResponse? = nil

    var body: some View {
        ZStack {
            if step == .main {
                MainContainerView(dashboardData: dashboardData)
                    .transition(.opacity)
            }

            if step == .onboarding {
                OnboardingFlowView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        step = .paywall
                    }
                }
                .transition(.opacity)
            }

            if step == .paywall {
                PaywallView {
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
                        step = .onboarding
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}
