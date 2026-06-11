import Foundation
import SwiftUI
import Combine

struct InsightUIModel {
    let emoji: String
    let accentColor: Color
    let credibilityText: String
    let mainTitle: String
    let bodyText: String
    let date: String
    let linkURL: String?
}

struct HomeProductUIModel: Identifiable {
    let id: String
    let name: String
    let brand: String
    let imageUrl: String?
    let timeAgoText: String
    let product: Product?
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var scannedCount: String = "0"
    @Published var sortedCount: String = "0"
    @Published var tipUIModel: InsightUIModel?
    @Published var newsUIModel: InsightUIModel?
    @Published var recentScans: [HomeProductUIModel] = []
    private let metricsRepository: MetricsRepositoryProtocol
    
    private static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.unitsStyle = .full
        return formatter
    }()
    
    init(
        metricsRepository: MetricsRepositoryProtocol,
        dashboardData: DailyDashboardResponse?,
        languageProvider: LanguageProvider
    ) {
        self.metricsRepository = metricsRepository
        
        let lang = languageProvider.currentLanguageCode
        self.tipUIModel = Self.createTipUIModel(from: dashboardData?.tip, lang: lang)
        self.newsUIModel = Self.createNewsUIModel(from: dashboardData?.news.first, lang: lang)
        
        loadMetrics()
    }
    
    func loadMetrics() {
        self.scannedCount = "\(metricsRepository.getScannedCount())"
        self.sortedCount = "\(metricsRepository.getSortedCount())"
    }
    
    func updateHistory(_ history: [ScannedHistoryModel]) {
        loadMetrics()
        self.recentScans = history.prefix(5).map { item in
            var decodedProduct = try? JSONDecoder().decode(Product.self, from: item.productData)
            decodedProduct?.barcode = item.id
            return HomeProductUIModel(
                id: item.id,
                name: item.productName,
                brand: item.brand,
                imageUrl: item.imageUrl,
                timeAgoText: timeAgo(from: item.scanDate),
                product: decodedProduct
            )
        }
    }
        
    private static func createTipUIModel(from tip: DailyTip?, lang: String) -> InsightUIModel? {
        guard let tip = tip else { return nil }
        return InsightUIModel(emoji: "🌿", accentColor: .appAccent, credibilityText: "ReFood Team", mainTitle: String(localized: "home_tip_title"), bodyText: (lang == "ua") ? tip.adviceUa : tip.adviceEn, date: tip.tipDate, linkURL: nil)
    }
    
    private static func createNewsUIModel(from news: DailyNews?, lang: String) -> InsightUIModel? {
        guard let news = news else { return nil }
        let title = (lang == "ua") ? (news.simplifiedTitleUa ?? "Новина") : (news.simplifiedTitleEn ?? "News")
        return InsightUIModel(emoji: "📰", accentColor: .appAccent, credibilityText: news.resource, mainTitle: String(localized: "home_news_title"), bodyText: title, date: formatDashboardDate(news.date, lang: lang), linkURL: news.link)
    }
    
    private static func formatDashboardDate(_ dateString: String, lang: String) -> String {
        let decoder = DateFormatter(); decoder.dateFormat = "yyyy-MMMM-dd"; decoder.locale = Locale(identifier: "en_US_POSIX")
        guard let date = decoder.date(from: dateString) else { return dateString }
        let encoder = DateFormatter(); encoder.dateFormat = "d MMMM"; encoder.locale = Locale(identifier: lang)
        return encoder.string(from: date)
    }
    
    private func timeAgo(from date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 60 { return String(localized: "search_time_just_now") }
        return Self.relativeDateTimeFormatter.localizedString(for: date, relativeTo: Date())
    }
}
