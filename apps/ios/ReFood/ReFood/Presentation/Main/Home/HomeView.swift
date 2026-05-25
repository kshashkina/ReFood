import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \ScannedHistoryModel.scanDate, order: .reverse) private var history: [ScannedHistoryModel]
    @StateObject private var vm: HomeViewModel
    
    var onProductTap: (Product) -> Void
    var onSeeAllTap: () -> Void
    
    init(
        dashboardData: DailyDashboardResponse?,
        languageProvider: LanguageProvider,
        metricsRepository: MetricsRepositoryProtocol,
        onProductTap: @escaping (Product) -> Void = { _ in },
        onSeeAllTap: @escaping () -> Void = {}
    ) {
        self.onProductTap = onProductTap
        self.onSeeAllTap = onSeeAllTap
        self._vm = StateObject(wrappedValue: HomeViewModel(metricsRepository: metricsRepository, dashboardData: dashboardData, languageProvider: languageProvider))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                MainHeaderView(title: "ReFood").padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        metricsSection
                        insightsSection
                        recentScansSection
                        Spacer(minLength: 160)
                    }.padding(.top, 8)
                }
            }
        }
        .onAppear {
            vm.loadMetrics()
            vm.updateHistory(history)
        }
        .onChange(of: history) { newHistory in
            vm.updateHistory(newHistory)
        }
    }
    
    private var metricsSection: some View {
        HStack(spacing: 16) {
            MainStatCard(title: String(localized: "home_stat_scanned"), value: vm.scannedCount, icon: "qrcode.viewfinder")
            MainStatCard(title: String(localized: "home_stat_sorted"), value: vm.sortedCount, icon: "leaf.arrow.triangle.circlepath")
        }.padding(.horizontal, 24).padding(.bottom, 24)
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            if let tipModel = vm.tipUIModel { InsightCard(model: tipModel) }
            if let newsModel = vm.newsUIModel { InsightCard(model: newsModel) }
        }.padding(.horizontal, 24).padding(.bottom, 32)
    }
    
    private var recentScansSection: some View {
        RecentScansSection(
            uiModels: vm.recentScans,
            onProductTap: onProductTap,
            onSeeAllTap: onSeeAllTap
        ).padding(.horizontal, 24)
    }
}
