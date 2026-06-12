import XCTest
@testable import ReFood

@MainActor
final class ManualInputViewModelTests: XCTestCase {
    
    var sut: ManualInputViewModel!
    var mockRepo: MockProductRepository!
    var mockHistoryRepo: MockSearchHistoryRepository!
    var mockMetricsRepo: MockMetricsRepository!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockProductRepository()
        mockHistoryRepo = MockSearchHistoryRepository()
        mockMetricsRepo = MockMetricsRepository()
        sut = ManualInputViewModel(
            repository: mockRepo,
            historyRepository: mockHistoryRepo,
            metricsRepository: mockMetricsRepo
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRepo = nil
        mockHistoryRepo = nil
        mockMetricsRepo = nil
        super.tearDown()
    }
    
    func test_isInputValid_whenBarcodeIsTooShort_shouldReturnFalse() {
        sut.barcode = "123456"
        XCTAssertFalse(sut.isInputValid, "Barcode shorter than 7 characters should be invalid")
    }
    
    func test_isInputValid_whenBarcodeIsTooLong_shouldReturnFalse() {
        sut.barcode = "123456789012345"
        XCTAssertFalse(sut.isInputValid, "Barcode longer than 14 characters should be invalid")
    }
    
    func test_isInputValid_whenBarcodeIsCorrect_shouldReturnTrue() {
        sut.barcode = "1234567890123"
        XCTAssertTrue(sut.isInputValid, "Correct 13-digit barcode should be valid")
    }
    
    func test_isInputValid_whenIsLoadingIsTrue_shouldReturnFalse() {
        sut.barcode = "1234567890123"
        sut.isLoading = true
        XCTAssertFalse(sut.isInputValid, "Input should be disabled while loading")
    }
    
    func test_isInputValid_ignoresWhitespaces() {
        sut.barcode = "  123456789  "
        XCTAssertTrue(sut.isInputValid, "Spaces should be trimmed when validating length")
    }
    
    func test_findProduct_successFlow() async {
        sut.barcode = "1234567890123"
        mockRepo.mockProduct = createMockProduct(barcode: "1234567890123", name: "Test Apple")
        
        await sut.findProduct()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(sut.isFailed)
        XCTAssertNil(sut.error)
        XCTAssertNotNil(sut.product)
        XCTAssertEqual(sut.product?.productName, "Test Apple")
        XCTAssertEqual(sut.loadingProgress, 1.0)
        XCTAssertEqual(sut.currentStep, .ready)
        
        XCTAssertTrue(mockMetricsRepo.incrementScannedCountCalled, "Metrics repository should be called to increment scan count")
        XCTAssertTrue(mockRepo.recordScanCalled, "Product repository should be called to record scan on backend")
    }
    
    
    func test_findProduct_resetsState_beforeNextSearch() async {
        sut.isFailed = true
        sut.error = "Old Error"
        sut.barcode = "1234567890123"
        mockRepo.mockProduct = createMockProduct(barcode: "1234567890123", name: "New One")
        mockRepo.shouldReturnError = false

        await sut.findProduct()
        
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(sut.isFailed, "State should be reset before new search")
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.product?.productName, "New One")
    }
    
    func test_findProduct_loadingProgress_stopsAtNinetyPercent() async {
        sut.barcode = "1234567890123"
        mockRepo.mockProduct = createMockProduct(barcode: "1234567890123", name: "Progress Test")
        
        let searchTask = Task {
            await sut.findProduct()
        }
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertLessThanOrEqual(sut.loadingProgress, 0.9, "Progress should wait at 90% until server responds")
        
        await searchTask.value
    }
    
    func test_findProduct_preventsConcurrentRequests() async {
        sut.barcode = "1234567890123"
        mockRepo.mockProduct = createMockProduct(barcode: "1234567890123", name: "Single")

        async let firstCall: () = sut.findProduct()
        async let secondCall: () = sut.findProduct()
        
        _ = await [firstCall, secondCall]
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertNotNil(sut.product)
    }

    func test_findProduct_whenInputIsInvalid_shouldNotMakeRequest() async {
        sut.barcode = "123"
        
        await sut.findProduct()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.product)
    }

    private func createMockProduct(barcode: String, name: String) -> Product {
        return Product(
            barcode: barcode,
            productName: name,
            brands: nil,
            quantity: nil,
            imageUrl: nil,
            analysisEn: nil,
            analysisUa: nil,
            categoriesTagsEn: nil,
            categoriesTagsUa: nil,
            ingredientsEn: nil,
            ingredientsUa: nil,
            allergensEn: nil,
            allergensUa: nil,
            packagingEn: nil,
            packagingUa: nil,
            nutriscoreGrade: nil,
            ecoscoreGrade: nil,
            novaGroup: nil,
            nutriments: nil
        )
    }
}
