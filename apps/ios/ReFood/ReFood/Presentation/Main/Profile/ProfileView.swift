import SwiftUI

struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel
    private let metricsRepository: MetricsRepositoryProtocol
    private let emailService: EmailServiceProtocol
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let localStorage: LocalStorageProtocol
    let analytics: AnalyticsServiceProtocol
    
    @State private var showAchievements = false
    @State private var showHelp = false
    @State private var showSettings = false
    
    init(
        metricsRepository: MetricsRepositoryProtocol,
        emailService: EmailServiceProtocol,
        linkAccountUseCase: LinkAppleAccountUseCase,
        deleteAccountUseCase: DeleteAccountUseCase,
        localStorage: LocalStorageProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.metricsRepository = metricsRepository
        self.emailService = emailService
        self.deleteAccountUseCase = deleteAccountUseCase
        self.localStorage = localStorage
        self.analytics = analytics
        self._vm = StateObject(wrappedValue: ProfileViewModel(
            metricsRepository: metricsRepository,
            linkAccountUseCase: linkAccountUseCase,
            localStorage: localStorage
        ))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                MainHeaderView(title: String(localized: "tab_profile"))
                    .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if !vm.isLinked {
                            ProfileAuthCard(action: {
                                analytics.track(ProfileEvent.signInTap)
                                vm.linkAppleAccount()
                            })
                            .opacity(vm.isLoading ? 0.5 : 1.0)
                            .disabled(vm.isLoading)
                        } else {
                            ProfileLinkedCard(
                                greeting: vm.greetingText,
                                subtitle: String(localized: "profile_linked_subtitle")
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "profile_section_statistics"))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ProfileStatCard(icon: "qrcode.viewfinder", value: vm.scannedCount, title: String(localized: "profile_stat_scanned"), iconColor: .appAccent)
                                ProfileStatCard(icon: "leaf.arrow.triangle.circlepath", value: vm.sortedCount, title: String(localized: "profile_stat_sorted"), iconColor: .appAccent)
                                ProfileStatCard(icon: "chart.xyaxis.line", value: vm.streakCount, title: String(localized: "profile_stat_streak"), iconColor: .appAccent)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            ProfileRowButton(icon: "rosette", title: String(localized: "profile_menu_achievements"), iconTint: .appAccent) {
                                analytics.track(ProfileEvent.achievementsTap)
                                showAchievements = true
                            }
                            ProfileRowButton(icon: "gearshape", title: String(localized: "profile_menu_settings")) {
                                analytics.track(ProfileEvent.settingsTap)
                                showSettings = true
                            }
                            ProfileRowButton(icon: "questionmark.circle", title: String(localized: "profile_menu_help")) {
                                analytics.track(ProfileEvent.helpTap)
                                showHelp = true
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 160)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
            
            if vm.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            let state = vm.isLinked ? "in" : "out"
            analytics.track(ProfileEvent.screenView(state: state))
            
            vm.loadMetrics()
        }
        .fullScreenCover(isPresented: $showAchievements) {
            AchievementsView(metricsRepository: metricsRepository, analytics: analytics, onBack: { showAchievements = false })
        }
        .fullScreenCover(isPresented: $showHelp) {
            HelpView(emailService: emailService, analytics: analytics,onBack: { showHelp = false })
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(deleteAccountUseCase: deleteAccountUseCase, localStorage: localStorage, analytics: analytics, onBack: { showSettings = false })
        }
    }
}
