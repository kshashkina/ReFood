import XCTest
@testable import ReFood

@MainActor
final class ProductPreviewViewModelTests: XCTestCase {
    
    var sut: ProductPreviewViewModel!
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
    
    func test_imageUrl_whenProductHasValidImageUrl_shouldReturnURL() {
        sut = makeSUT(product: createMockProduct(imageUrl: "https://example.com/image.png"))
        
        XCTAssertEqual(sut.imageUrl?.absoluteString, "https://example.com/image.png")
    }
    
    func test_imageUrl_whenProductImageUrlIsNil_shouldReturnNil() {
        sut = makeSUT(product: createMockProduct(imageUrl: nil))
        
        XCTAssertNil(sut.imageUrl)
    }
    
    func test_imageUrl_whenProductImageUrlIsInvalid_shouldReturnNil() {
        sut = makeSUT(product: createMockProduct(imageUrl: ""))
        
        XCTAssertNil(sut.imageUrl)
    }
    
    func test_productName_whenProductHasName_shouldReturnName() {
        sut = makeSUT(product: createMockProduct(productName: "Apple"))
        
        XCTAssertEqual(sut.productName, "Apple")
    }
    
    func test_productName_whenProductNameIsNil_shouldReturnLocalizedUnknown() {
        sut = makeSUT(product: createMockProduct(productName: nil))
        
        XCTAssertEqual(sut.productName, String(localized: "common_unknown"))
    }
    
    func test_brandName_whenProductHasBrand_shouldReturnBrand() {
        sut = makeSUT(product: createMockProduct(brands: "Brand A"))
        
        XCTAssertEqual(sut.brandName, "Brand A")
    }
    
    func test_brandName_whenBrandsAreNil_shouldReturnEmptyString() {
        sut = makeSUT(product: createMockProduct(brands: nil))
        
        XCTAssertEqual(sut.brandName, "")
    }
    
    func test_continueButtonTitle_whenNoFirstProductForComparison_shouldReturnContinueTitle() {
        sut = makeSUT(
            product: createMockProduct(),
            firstProductForComparison: nil
        )
        
        XCTAssertEqual(sut.continueButtonTitle, String(localized: "preview_btn_continue"))
    }
    
    func test_continueButtonTitle_whenFirstProductHasOneBrand_shouldReturnCompareTitleWithBrand() {
        let firstProduct = createMockProduct(brands: "Brand A")
        sut = makeSUT(
            product: createMockProduct(),
            firstProductForComparison: firstProduct
        )
        
        let expected = String(
            format: String(localized: "preview_btn_compare"),
            "Brand A"
        )
        
        XCTAssertEqual(sut.continueButtonTitle, expected)
    }
    
    func test_continueButtonTitle_whenFirstProductHasMultipleBrands_shouldUseFirstBrand() {
        let firstProduct = createMockProduct(brands: "Brand A, Brand B")
        sut = makeSUT(
            product: createMockProduct(),
            firstProductForComparison: firstProduct
        )
        
        let expected = String(
            format: String(localized: "preview_btn_compare"),
            "Brand A"
        )
        
        XCTAssertEqual(sut.continueButtonTitle, expected)
    }
    
    func test_continueButtonTitle_whenFirstProductBrandIsNil_shouldUsePreviousItemFallback() {
        let firstProduct = createMockProduct(brands: nil)
        sut = makeSUT(
            product: createMockProduct(),
            firstProductForComparison: firstProduct
        )
        
        let expected = String(
            format: String(localized: "preview_btn_compare"),
            String(localized: "preview_previous_item")
        )
        
        XCTAssertEqual(sut.continueButtonTitle, expected)
    }
    
    private func makeSUT(
        product: Product,
        firstProductForComparison: Product? = nil
    ) -> ProductPreviewViewModel {
        ProductPreviewViewModel(
            product: product,
            firstProductForComparison: firstProductForComparison,
            languageProvider: mockLanguageProvider
        )
    }
    
    private func createMockProduct(
        productName: String? = "Test Product",
        brands: String? = "Test Brand",
        imageUrl: String? = nil
    ) -> Product {
        Product(
            barcode: "1234567890123",
            productName: productName,
            brands: brands,
            quantity: nil,
            imageUrl: imageUrl,
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
