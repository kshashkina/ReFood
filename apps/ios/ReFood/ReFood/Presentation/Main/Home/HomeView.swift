import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \ScannedHistoryModel.scanDate, order: .reverse) private var history: [ScannedHistoryModel]
    @StateObject private var vm: HomeViewModel
    
    let analytics: AnalyticsServiceProtocol
    var onProductTap: (Product) -> Void
    var onSeeAllTap: () -> Void
    
    init(
        dashboardData: DailyDashboardResponse?,
        languageProvider: LanguageProvider,
        metricsRepository: MetricsRepository,
        analytics: AnalyticsServiceProtocol,
        onProductTap: @escaping (Product) -> Void = { _ in },
        onSeeAllTap: @escaping () -> Void = {}
    ) {
        self.analytics = analytics
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
            
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.8), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            analytics.track(HomeEvent.screenView)
            vm.loadMetrics()
            vm.updateHistory(history)
        }
        .onChange(of: history) { newHistory in
            vm.updateHistory(newHistory)
            vm.loadMetrics() 
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
            if let newsModel = vm.newsUIModel {
                InsightCard(model: newsModel, onLinkTap: {
                    analytics.track(HomeEvent.articleTap)
                })
            }
        }.padding(.horizontal, 24).padding(.bottom, 32)
    }
    
    private var recentScansSection: some View {
        RecentScansSection(
            uiModels: vm.recentScans,
            onProductTap: { product in
                analytics.track(HomeEvent.productTap(barcode: product.id))
                onProductTap(product)
            },
            onSeeAllTap: {
                analytics.track(HomeEvent.seeAllTap)
                onSeeAllTap()
            }
        ).padding(.horizontal, 24)
    }
}
