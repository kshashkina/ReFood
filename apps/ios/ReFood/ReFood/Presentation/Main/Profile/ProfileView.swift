import SwiftUI

struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel
    
    init(metricsRepository: MetricsRepositoryProtocol) {
        self._vm = StateObject(wrappedValue: ProfileViewModel(metricsRepository: metricsRepository))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                MainHeaderView(title: String(localized: "tab_profile"))
                    .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        ProfileAuthCard(action: {
                        })
                        
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
                            ProfileRowButton(icon: "rosette", title: String(localized: "profile_menu_achievements"), iconTint: .appAccent) { }
                            
                            ProfileRowButton(icon: "gearshape", title: String(localized: "profile_menu_settings")) { }
                            ProfileRowButton(icon: "questionmark.circle", title: String(localized: "profile_menu_help")) { }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 160)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            vm.loadMetrics()
        }
    }
}
