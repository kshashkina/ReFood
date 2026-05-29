import SwiftUI

struct OnboardingFlowView: View {
    let analytics: AnalyticsServiceProtocol
    var onFinish: () -> Void = {}

    @State private var index: Int = 0
    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    private let pages: [OnboardingPage] = [
        .init(title: "onboarding_page1_title", subtitle: "onboarding_page1_subtitle", imageName: "ONB_1"),
        .init(title: "onboarding_page2_title", subtitle: "onboarding_page2_subtitle", imageName: "ONB_2"),
        .init(title: "onboarding_page3_title", subtitle: "onboarding_page3_subtitle", imageName: "ONB_3")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.offset) { i, page in
                    OnboardingPageView(page: page)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: index) { newIndex in
                analytics.track(OnboardingEvent.screenView(step: newIndex + 1))
            }
            .onAppear {
                analytics.track(OnboardingEvent.screenView(step: index + 1))
            }

            VStack(spacing: 32) {
                Spacer()

                Dots(total: pages.count, current: index)

                PrimaryButton(
                    title: index < pages.count - 1 ? String(localized: "onboarding_btn_next") : String(localized: "onboarding_btn_start")
                ) {
                    analytics.track(OnboardingEvent.continueTap(step: index + 1))
                    if index < pages.count - 1 {
                        withAnimation(.easeInOut) { index += 1 }
                    } else {
                        onFinish()
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

private struct Dots: View {
    let total: Int
    let current: Int
    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? green : .white.opacity(0.20))
                    .frame(width: i == current ? 32 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
        .frame(height: 8)
    }
}
