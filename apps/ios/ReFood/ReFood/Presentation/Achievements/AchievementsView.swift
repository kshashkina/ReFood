import SwiftUI

struct AchievementsView: View {
    @StateObject private var vm: AchievementsViewModel
    let onBack: () -> Void
    
    init(metricsRepository: MetricsRepositoryProtocol, onBack: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: AchievementsViewModel(metricsRepository: metricsRepository))
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    AchievementProgressHeader(progressText: vm.unlockedCountText, fraction: vm.totalProgressFraction)
                        .padding(.top, 90)
                    VStack(spacing: 12) {
                        ForEach(vm.achievements) { item in
                            AchievementRow(model: item)
                        }
                    }
                    VStack(spacing: 6) {
                        Text(String(localized: "achievement_footer_text_1"))
                        HStack(spacing: 4) {
                            Text(String(localized: "achievement_footer_text_2"))
                            Image(systemName: "leaf.fill").foregroundColor(.appAccent)
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            AchievementsTopBar(onBack: onBack)
        }
        .navigationBarHidden(true)
    }
}
