import XCTest
@testable import ReFood

@MainActor
final class RecyclingViewModelTests: XCTestCase {
    
    var sut: RecyclingViewModel!
    var mockLanguageProvider: MockLanguageProvider!
    
    override func setUp() {
        super.setUp()
        mockLanguageProvider = MockLanguageProvider()
    }
    
    override func tearDown() {
        sut = nil
        mockLanguageProvider = nil
        super.tearDown()
    }
    
    func test_productName_whenProductHasName_shouldReturnName() {
        sut = makeSUT(product: createMockProduct(name: "Apple"))
        
        XCTAssertEqual(sut.productName, "Apple")
    }
    
    func test_productName_whenProductNameIsNil_shouldReturnLocalizedUnknownText() {
        sut = makeSUT(product: createMockProduct(name: nil))
        
        XCTAssertEqual(sut.productName, String(localized: "common_unknown"))
    }
    
    func test_primaryBrand_whenProductHasMultipleBrands_shouldReturnFirstBrand() {
        sut = makeSUT(product: createMockProduct(brands: "Brand A, Brand B"))
        
        XCTAssertEqual(sut.primaryBrand, "Brand A")
    }
    
    func test_primaryBrand_whenBrandsAreNil_shouldReturnEmptyString() {
        sut = makeSUT(product: createMockProduct(brands: nil))
        
        XCTAssertEqual(sut.primaryBrand, "")
    }
    
    func test_hasPackagingData_whenPackagingExists_shouldReturnTrue() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ]
        ))
        
        XCTAssertTrue(sut.hasPackagingData)
    }
    
    func test_hasPackagingData_whenPackagingIsEmpty_shouldReturnFalse() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(packagingEn: []))
        
        XCTAssertFalse(sut.hasPackagingData)
    }
    
    func test_hasPackagingData_whenPackagingIsNil_shouldReturnFalse() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(packagingEn: nil))
        
        XCTAssertFalse(sut.hasPackagingData)
    }
    
    func test_components_whenLanguageIsEnglish_shouldUseEnglishPackaging() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ],
            packagingUa: [
                createMockPackagingItem(shape: "пляшка", material: "пластик")
            ]
        ))
        
        XCTAssertEqual(sut.components.count, 1)
        XCTAssertEqual(sut.components.first?.shapeTitle, "Bottle")
        XCTAssertEqual(sut.components.first?.materialTitle, "Plastic")
    }
    
    func test_components_whenLanguageIsUkrainian_shouldUseUkrainianPackaging() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ],
            packagingUa: [
                createMockPackagingItem(shape: "пляшка", material: "пластик")
            ]
        ))
        
        XCTAssertEqual(sut.components.count, 1)
        XCTAssertEqual(sut.components.first?.shapeTitle, "Пляшка")
        XCTAssertEqual(sut.components.first?.materialTitle, "Пластик")
    }
    
    func test_components_whenShapeAndMaterialAreNil_shouldReturnLocalizedFallbackTexts() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: nil, material: nil)
            ]
        ))
        
        XCTAssertEqual(sut.components.first?.shapeTitle, String(localized: "recycling_packaging_element"))
        XCTAssertEqual(sut.components.first?.materialTitle, String(localized: "recycling_unknown_material"))
    }
    
    func test_components_whenPackagingHasMultipleItems_shouldReturnAllComponents() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic"),
                createMockPackagingItem(shape: "lid", material: "metal")
            ]
        ))
        
        XCTAssertEqual(sut.components.count, 2)
        XCTAssertEqual(sut.components[0].shapeTitle, "Bottle")
        XCTAssertEqual(sut.components[0].materialTitle, "Plastic")
        XCTAssertEqual(sut.components[1].shapeTitle, "Lid")
        XCTAssertEqual(sut.components[1].materialTitle, "Metal")
    }
    
    func test_components_shouldContainCategoryTitleAndPreparationSteps() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ]
        ))
        
        XCTAssertFalse(sut.components.first?.categoryTitle.isEmpty ?? true)
        XCTAssertFalse(sut.components.first?.preparationSteps.isEmpty ?? true)
    }
    
    func test_standardWasteTypes_shouldContainSixTypes() {
        sut = makeSUT(product: createMockProduct())
        
        XCTAssertEqual(sut.standardWasteTypes.count, 6)
    }
    
    func test_standardWasteTypes_shouldContainCorrectTitleKeys() {
        sut = makeSUT(product: createMockProduct())
        
        let titleKeys = sut.standardWasteTypes.map { $0.titleKey }
        
        XCTAssertEqual(titleKeys, [
            "recycling_type_paper",
            "recycling_type_plastic",
            "recycling_type_glass",
            "recycling_type_metal",
            "recycling_type_organic",
            "recycling_type_mixed"
        ])
    }
    
    private func makeSUT(product: Product) -> RecyclingViewModel {
        RecyclingViewModel(
            product: product,
            languageProvider: mockLanguageProvider
        )
    }
    
    private func createMockProduct(
        name: String? = "Test Product",
        brands: String? = "Test Brand",
        packagingEn: [PackagingItem]? = nil,
        packagingUa: [PackagingItem]? = nil
    ) -> Product {
        Product(
            barcode: "1234567890123",
            productName: name,
            brands: brands,
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
            packagingEn: packagingEn,
            packagingUa: packagingUa,
            nutriscoreGrade: nil,
            ecoscoreGrade: nil,
            novaGroup: nil,
            nutriments: nil
        )
    }
    
    private func createMockPackagingItem(
        shape: String?,
        material: String?,
        recycling: String? = nil,
        numberOfUnits: Int? = nil
    ) -> PackagingItem {
        PackagingItem(
            numberOfUnits: numberOfUnits,
            material: material,
            recycling: recycling,
            shape: shape
        )
    }
}

