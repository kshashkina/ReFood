import XCTest
@testable import ReFood

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    var mockMetricsRepository: MockMetricsRepository!
    var mockLanguageProvider: MockLanguageProvider!
    
    override func setUp() {
        super.setUp()
        mockMetricsRepository = MockMetricsRepository()
        mockLanguageProvider = MockLanguageProvider()
    }
    
    override func tearDown() {
        sut = nil
        mockMetricsRepository = nil
        mockLanguageProvider = nil
        super.tearDown()
    }
    
    func test_loadMetrics_shouldSetCorrectCounts() {
        mockMetricsRepository.scannedCount = 12
        mockMetricsRepository.sortedCount = 5
        
        sut = makeSUT()
        
        sut.loadMetrics()
        
        XCTAssertEqual(sut.scannedCount, "12")
        XCTAssertEqual(sut.sortedCount, "5")
    }
    
    func test_init_whenDashboardContainsTip_shouldCreateTipUIModel() {
        let dashboard = createDashboard()
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertNotNil(sut.tipUIModel)
    }
    
    func test_init_whenDashboardContainsNews_shouldCreateNewsUIModel() {
        let dashboard = createDashboard()
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertNotNil(sut.newsUIModel)
    }
    
    func test_tipUIModel_whenLanguageIsEnglish_shouldUseEnglishAdvice() {
        mockLanguageProvider.currentLanguageCode = "en"
        
        let dashboard = createDashboard(
            tip: DailyTip(
                tipDate: "2025-April-10",
                adviceEn: "English Tip",
                adviceUa: "Українська порада"
            )
        )
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertEqual(sut.tipUIModel?.bodyText, "English Tip")
    }
    
    func test_tipUIModel_whenLanguageIsUkrainian_shouldUseUkrainianAdvice() {
        mockLanguageProvider.currentLanguageCode = "ua"
        
        let dashboard = createDashboard(
            tip: DailyTip(
                tipDate: "2025-April-10",
                adviceEn: "English Tip",
                adviceUa: "Українська порада"
            )
        )
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertEqual(sut.tipUIModel?.bodyText, "Українська порада")
    }
    
    func test_newsUIModel_whenLanguageIsEnglish_shouldUseEnglishTitle() {
        mockLanguageProvider.currentLanguageCode = "en"
        
        let dashboard = createDashboard(
            news: [
                DailyNews(
                    id: "1",
                    date: "2025-April-10",
                    resource: "BBC",
                    link: "https://example.com",
                    newsType: "eco",
                    simplifiedTitleUa: "Українська новина",
                    simplifiedTitleEn: "English News",
                    takeawayUa: nil,
                    takeawayEn: nil
                )
            ]
        )
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertEqual(sut.newsUIModel?.bodyText, "English News")
    }
    
    func test_newsUIModel_whenLanguageIsUkrainian_shouldUseUkrainianTitle() {
        mockLanguageProvider.currentLanguageCode = "ua"
        
        let dashboard = createDashboard(
            news: [
                DailyNews(
                    id: "1",
                    date: "2025-April-10",
                    resource: "BBC",
                    link: "https://example.com",
                    newsType: "eco",
                    simplifiedTitleUa: "Українська новина",
                    simplifiedTitleEn: "English News",
                    takeawayUa: nil,
                    takeawayEn: nil
                )
            ]
        )
        
        sut = makeSUT(dashboard: dashboard)
        
        XCTAssertEqual(sut.newsUIModel?.bodyText, "Українська новина")
    }
    
    func test_updateHistory_shouldTakeOnlyFirstFiveItems() {
        sut = makeSUT()
        
        let history = (1...7).map {
            createHistoryModel(id: "\($0)", name: "Product \($0)")
        }
        
        sut.updateHistory(history)
        
        XCTAssertEqual(sut.recentScans.count, 5)
    }
    
    func test_updateHistory_shouldDecodeProduct() {
        sut = makeSUT()
        
        let history = [
            createHistoryModel(id: "1", name: "Apple")
        ]
        
        sut.updateHistory(history)
        
        XCTAssertEqual(sut.recentScans.first?.product?.productName, "Apple")
    }
    
    func test_updateHistory_whenProductDataIsInvalid_shouldSetNilProduct() {
        sut = makeSUT()
        
        let broken = ScannedHistoryModel(
            id: "1",
            productData: Data("broken".utf8),
            scanDate: Date(),
            isFavorite: false,
            productName: "Broken",
            brand: "Brand",
            imageUrl: nil
        )
        
        sut.updateHistory([broken])
        
        XCTAssertNil(sut.recentScans.first?.product)
    }
    
    func test_updateHistory_whenDateIsLessThanMinuteAgo_shouldReturnJustNow() {
        sut = makeSUT()
        
        let history = [
            createHistoryModel(
                id: "1",
                scanDate: Date().addingTimeInterval(-20)
            )
        ]
        
        sut.updateHistory(history)
        
        XCTAssertEqual(
            sut.recentScans.first?.timeAgoText,
            String(localized: "search_time_just_now")
        )
    }
    
    func test_updateHistory_shouldAlsoReloadMetrics() {
        mockMetricsRepository.scannedCount = 9
        mockMetricsRepository.sortedCount = 2
        
        sut = makeSUT()
        
        sut.updateHistory([])
        
        XCTAssertEqual(sut.scannedCount, "9")
        XCTAssertEqual(sut.sortedCount, "2")
    }
    
    private func makeSUT(
        dashboard: DailyDashboardResponse? = nil
    ) -> HomeViewModel {
        HomeViewModel(
            metricsRepository: mockMetricsRepository,
            dashboardData: dashboard,
            languageProvider: mockLanguageProvider
        )
    }
    
    private func createDashboard(
        tip: DailyTip = DailyTip(
            tipDate: "2025-April-10",
            adviceEn: "Tip EN",
            adviceUa: "Tip UA"
        ),
        news: [DailyNews] = [
            DailyNews(
                id: "1",
                date: "2025-April-10",
                resource: "BBC",
                link: "https://example.com",
                newsType: "eco",
                simplifiedTitleUa: "News UA",
                simplifiedTitleEn: "News EN",
                takeawayUa: nil,
                takeawayEn: nil
            )
        ]
    ) -> DailyDashboardResponse {
        DailyDashboardResponse(
            dateUtc: "2025-April-10",
            tip: tip,
            news: news
        )
    }
    
    private func createHistoryModel(
        id: String,
        name: String = "Test Product",
        brand: String = "Test Brand",
        imageUrl: String? = nil,
        scanDate: Date = Date().addingTimeInterval(-3600)
    ) -> ScannedHistoryModel {
        ScannedHistoryModel(
            id: id,
            productData: createProductData(
                barcode: id,
                productName: name,
                brands: brand,
                imageUrl: imageUrl
            ),
            scanDate: scanDate,
            isFavorite: false,
            productName: name,
            brand: brand,
            imageUrl: imageUrl
        )
    }
    
    private func createProductData(
        barcode: String,
        productName: String,
        brands: String,
        imageUrl: String?
    ) -> Data {
        let json: [String: Any] = [
            "barcode": barcode,
            "product_name": productName,
            "brands": brands,
            "image_url": imageUrl ?? ""
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
