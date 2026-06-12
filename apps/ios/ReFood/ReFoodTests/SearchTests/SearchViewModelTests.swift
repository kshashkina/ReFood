import XCTest
import SwiftData
@testable import ReFood

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var sut: SearchViewModel!
    var mockHistoryRepository: MockSearchHistoryRepository!
    var mockProductRepository: MockProductRepository!
    
    override func setUp() {
        super.setUp()
        mockHistoryRepository = MockSearchHistoryRepository()
        mockProductRepository = MockProductRepository()
        sut = SearchViewModel(historyRepository: mockHistoryRepository, productRepository: mockProductRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockHistoryRepository = nil
        mockProductRepository = nil
        super.tearDown()
    }
    
    func test_updateUIModels_shouldReturnAllHistoryItems() {
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        sut.updateUIModels(from: history)
        let result = sut.uiModels
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Apple")
        XCTAssertEqual(result[1].name, "Milk")
    }
    
    func test_updateUIModels_whenSearchTextMatchesName_shouldReturnMatchingItems() {
        sut.searchText = "app"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        sut.updateUIModels(from: history)
        let result = sut.uiModels
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Apple")
    }
    
    func test_updateUIModels_whenSearchTextMatchesBrand_shouldReturnMatchingItems() {
        sut.searchText = "brand b"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        sut.updateUIModels(from: history)
        let result = sut.uiModels
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.brand, "Brand B")
    }
    
    func test_updateUIModels_whenSearchTextDoesNotMatch_shouldReturnEmptyArray() {
        sut.searchText = "banana"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        sut.updateUIModels(from: history)
        
        XCTAssertTrue(sut.uiModels.isEmpty)
    }
    
    func test_updateUIModels_whenShowFavoritesOnlyIsTrue_shouldReturnOnlyFavorites() {
        sut.showFavoritesOnly = true
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A", isFavorite: true),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B", isFavorite: false)
        ]
        
        sut.updateUIModels(from: history)
        
        XCTAssertEqual(sut.uiModels.count, 1)
        XCTAssertEqual(sut.uiModels.first?.id, "1")
    }
    
    func test_updateUIModels_whenSearchAndFavoritesEnabled_shouldReturnOnlyMatchingFavoriteItems() {
        sut.searchText = "apple"
        sut.showFavoritesOnly = true
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A", isFavorite: true),
            createHistoryModel(id: "2", name: "Apple Juice", brand: "Brand B", isFavorite: false),
            createHistoryModel(id: "3", name: "Milk", brand: "Brand C", isFavorite: true)
        ]
        
        sut.updateUIModels(from: history)
        
        XCTAssertEqual(sut.uiModels.count, 1)
        XCTAssertEqual(sut.uiModels.first?.id, "1")
    }
    
    func test_updateUIModels_whenScanDateIsLessThanMinuteAgo_shouldReturnJustNow() {
        let history = [
            createHistoryModel(
                id: "1",
                name: "Apple",
                brand: "Brand A",
                scanDate: Date().addingTimeInterval(-30)
            )
        ]
        
        sut.updateUIModels(from: history)
        
        XCTAssertEqual(sut.uiModels.first?.timeAgo, String(localized: "search_time_just_now"))
    }
    
    func test_updateUIModels_whenProductDataIsValid_shouldDecodeProduct() {
        let model = createHistoryModel(id: "123456789", name: "Apple", brand: "Brand A")
        
        sut.updateUIModels(from: [model])
        
        XCTAssertNotNil(sut.uiModels.first?.product)
        XCTAssertEqual(sut.uiModels.first?.product?.productName, "Apple")
    }
    
    func test_updateUIModels_whenProductDataIsInvalid_shouldReturnNilProduct() {
        let model = ScannedHistoryModel(
            id: "1",
            productData: Data("invalid json".utf8),
            scanDate: Date(),
            isFavorite: false,
            productName: "Apple",
            brand: "Brand A",
            imageUrl: nil
        )
        
        sut.updateUIModels(from: [model])
        
        XCTAssertNil(sut.uiModels.first?.product)
    }
    
    func test_toggleFavorite_whenItemIsNotFavorite_shouldUpdateFavoriteToFalse() async {
        let model = createHistoryModel(id: "1", isFavorite: false)
        sut.updateUIModels(from: [model])
        guard let uiModel = sut.uiModels.first else { return XCTFail() }
        
        sut.toggleFavorite(for: uiModel)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockHistoryRepository.updatedFavoriteId, "1")
        XCTAssertEqual(mockHistoryRepository.updatedFavoriteStatus, false)
    }
    
    func test_toggleFavorite_whenItemIsFavorite_shouldUpdateFavoriteToTrue() async {
        let model = createHistoryModel(id: "1", isFavorite: true)
        sut.updateUIModels(from: [model])
        guard let uiModel = sut.uiModels.first else { return XCTFail() }
        
        sut.toggleFavorite(for: uiModel)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockHistoryRepository.updatedFavoriteId, "1")
        XCTAssertEqual(mockHistoryRepository.updatedFavoriteStatus, true)
    }
    
    func test_delete_shouldCallRepositoryDeleteWithCorrectId() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ScannedHistoryModel.self, configurations: config)
        let context = container.mainContext
        
        let model = createHistoryModel(id: "1")
        context.insert(model)
        
        sut.updateUIModels(from: [model])
        guard let uiModel = sut.uiModels.first else { return XCTFail() }
        
        sut.delete(uiModel: uiModel, context: context)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockHistoryRepository.deletedId, "1")
        XCTAssertTrue(sut.uiModels.isEmpty)
    }
    
    private func createHistoryModel(
        id: String = "123456789",
        name: String = "Test Product",
        brand: String = "Test Brand",
        imageUrl: String? = "https://example.com/image.png",
        scanDate: Date = Date().addingTimeInterval(-3600),
        isFavorite: Bool = false
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
            isFavorite: isFavorite,
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


