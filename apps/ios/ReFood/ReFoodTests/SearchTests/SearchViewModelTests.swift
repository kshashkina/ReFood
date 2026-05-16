import XCTest
@testable import ReFood

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var sut: SearchViewModel!
    var mockRepository: MockSearchHistoryRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSearchHistoryRepository()
        sut = SearchViewModel(historyRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func test_getUIModels_shouldReturnAllHistoryItems() {
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Apple")
        XCTAssertEqual(result[1].name, "Milk")
    }
    
    func test_getUIModels_whenSearchTextMatchesName_shouldReturnMatchingItems() {
        sut.searchText = "app"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Apple")
    }
    
    func test_getUIModels_whenSearchTextMatchesBrand_shouldReturnMatchingItems() {
        sut.searchText = "brand b"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.brand, "Brand B")
    }
    
    func test_getUIModels_whenSearchTextDoesNotMatch_shouldReturnEmptyArray() {
        sut.searchText = "banana"
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A"),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B")
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getUIModels_whenShowFavoritesOnlyIsTrue_shouldReturnOnlyFavorites() {
        sut.showFavoritesOnly = true
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A", isFavorite: true),
            createHistoryModel(id: "2", name: "Milk", brand: "Brand B", isFavorite: false)
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }
    
    func test_getUIModels_whenSearchAndFavoritesEnabled_shouldReturnOnlyMatchingFavoriteItems() {
        sut.searchText = "apple"
        sut.showFavoritesOnly = true
        
        let history = [
            createHistoryModel(id: "1", name: "Apple", brand: "Brand A", isFavorite: true),
            createHistoryModel(id: "2", name: "Apple Juice", brand: "Brand B", isFavorite: false),
            createHistoryModel(id: "3", name: "Milk", brand: "Brand C", isFavorite: true)
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }
    
    func test_getUIModels_whenScanDateIsLessThanMinuteAgo_shouldReturnJustNow() {
        let history = [
            createHistoryModel(
                id: "1",
                name: "Apple",
                brand: "Brand A",
                scanDate: Date().addingTimeInterval(-30)
            )
        ]
        
        let result = sut.getUIModels(from: history)
        
        XCTAssertEqual(result.first?.timeAgo, String(localized: "search_time_just_now"))
    }
    
    func test_searchItemUIModel_product_whenProductDataIsValid_shouldDecodeProduct() {
        let model = createHistoryModel(id: "123456789", name: "Apple", brand: "Brand A")
        
        let uiModel = SearchItemUIModel(
            originalModel: model,
            name: model.productName,
            brand: model.brand,
            imageUrl: model.imageUrl,
            timeAgo: "now"
        )
        
        XCTAssertNotNil(uiModel.product)
        XCTAssertEqual(uiModel.product?.productName, "Apple")
    }
    
    func test_searchItemUIModel_product_whenProductDataIsInvalid_shouldReturnNil() {
        let model = ScannedHistoryModel(
            id: "1",
            productData: Data("invalid json".utf8),
            scanDate: Date(),
            isFavorite: false,
            productName: "Apple",
            brand: "Brand A",
            imageUrl: nil
        )
        
        let uiModel = SearchItemUIModel(
            originalModel: model,
            name: model.productName,
            brand: model.brand,
            imageUrl: model.imageUrl,
            timeAgo: "now"
        )
        
        XCTAssertNil(uiModel.product)
    }
    
    func test_toggleFavorite_whenItemIsNotFavorite_shouldUpdateFavoriteToTrue() async {
        let model = createHistoryModel(id: "1", isFavorite: false)
        let uiModel = SearchItemUIModel(
            originalModel: model,
            name: model.productName,
            brand: model.brand,
            imageUrl: model.imageUrl,
            timeAgo: "now"
        )
        
        sut.toggleFavorite(for: uiModel)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockRepository.updatedFavoriteId, "1")
        XCTAssertEqual(mockRepository.updatedFavoriteStatus, true)
    }
    
    func test_toggleFavorite_whenItemIsFavorite_shouldUpdateFavoriteToFalse() async {
        let model = createHistoryModel(id: "1", isFavorite: true)
        let uiModel = SearchItemUIModel(
            originalModel: model,
            name: model.productName,
            brand: model.brand,
            imageUrl: model.imageUrl,
            timeAgo: "now"
        )
        
        sut.toggleFavorite(for: uiModel)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockRepository.updatedFavoriteId, "1")
        XCTAssertEqual(mockRepository.updatedFavoriteStatus, false)
    }
    
    func test_delete_shouldCallRepositoryDeleteWithCorrectId() async {
        let model = createHistoryModel(id: "1")
        let uiModel = SearchItemUIModel(
            originalModel: model,
            name: model.productName,
            brand: model.brand,
            imageUrl: model.imageUrl,
            timeAgo: "now"
        )
        
        sut.delete(uiModel: uiModel)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mockRepository.deletedId, "1")
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
