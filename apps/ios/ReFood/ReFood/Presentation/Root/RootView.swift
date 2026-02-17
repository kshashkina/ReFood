import SwiftUI

struct RootView: View {

    private enum Step {
        case splash
        case onboarding
        case paywall
    }

    @State private var step: Step = .splash

    var body: some View {
        ZStack {
            if step == .onboarding {
                OnboardingFlowView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        step = .paywall
                    }
                }
                .transition(.opacity)
            }

            if step == .paywall {
                PaywallView()
                    .transition(.opacity)
            }

            if step == .splash {
                SplashView {
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

#Preview {
    RootView()
}
