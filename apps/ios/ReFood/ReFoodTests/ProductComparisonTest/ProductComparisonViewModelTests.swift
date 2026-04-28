import XCTest
@testable import ReFood

@MainActor
final class ProductComparisonViewModelTests: XCTestCase {
    
    var sut: ProductComparisonViewModel!
    var mockAIRepo: MockAIComparisonRepository!
    var mockLanguageProvider: MockLanguageProvider!
    
    override func setUp() {
        super.setUp()
        mockAIRepo = MockAIComparisonRepository()
        mockLanguageProvider = MockLanguageProvider()
        
        sut = ProductComparisonViewModel(
            productA: createMockProduct(
                barcode: "111",
                name: "Apple",
                brands: "Brand A",
                nutriScore: "a",
                ecoScore: "b",
                nutriments: createMockNutriments(
                    kcal: 42,
                    proteins: 3,
                    fat: 1,
                    saturatedFat: 0.5,
                    carbs: 10,
                    sugars: 5,
                    salt: 0.1
                )
            ),
            productB: createMockProduct(
                barcode: "222",
                name: "Cookie",
                brands: "Brand B",
                nutriScore: "d",
                ecoScore: "c",
                nutriments: createMockNutriments(
                    kcal: 100,
                    proteins: 1,
                    fat: 5,
                    saturatedFat: 2,
                    carbs: 20,
                    sugars: 12,
                    salt: 0.5
                )
            ),
            aiRepository: mockAIRepo,
            languageProvider: mockLanguageProvider
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAIRepo = nil
        mockLanguageProvider = nil
        super.tearDown()
    }
    
    func test_fetchAIAnalysis_successFlow_shouldSetAIResultAndClearError() async {
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertFalse(sut.isAnalyzing)
        XCTAssertNil(sut.aiError)
        XCTAssertNotNil(sut.aiResult)
        XCTAssertEqual(sut.aiResult?.winnerBarcode, "111")
        XCTAssertTrue(mockAIRepo.getComparisonCalled)
        XCTAssertEqual(mockAIRepo.receivedBarcodeA, "111")
        XCTAssertEqual(mockAIRepo.receivedBarcodeB, "222")
    }
    
    func test_fetchAIAnalysis_failureFlow_shouldSetError() async {
        mockAIRepo.shouldReturnError = true
        
        await sut.fetchAIAnalysis()
        
        XCTAssertFalse(sut.isAnalyzing)
        XCTAssertNil(sut.aiResult)
        XCTAssertEqual(sut.aiError, "comparison_ai_error_message")
        XCTAssertTrue(sut.hasAIError)
    }
    
    func test_aiComparisonText_whenLanguageIsUkrainian_shouldReturnUkrainianText() async {
        mockLanguageProvider.currentLanguageCode = "ua"
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertEqual(sut.aiComparisonText, "Український аналіз")
    }
    
    func test_aiComparisonText_whenLanguageIsEnglish_shouldReturnEnglishText() async {
        mockLanguageProvider.currentLanguageCode = "en"
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertEqual(sut.aiComparisonText, "English analysis")
    }
    
    func test_aiDifferences_whenLanguageIsUkrainian_shouldReturnUkrainianDifferences() async {
        mockLanguageProvider.currentLanguageCode = "ua"
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertEqual(sut.aiDifferences, ["Менше цукру", "Кращий склад"])
    }
    
    func test_aiDifferences_whenLanguageIsEnglish_shouldReturnEnglishDifferences() async {
        mockLanguageProvider.currentLanguageCode = "en"
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertEqual(sut.aiDifferences, ["Less sugar", "Better ingredients"])
    }
    
    func test_isWinner_whenProductBarcodeMatchesWinnerBarcode_shouldReturnTrue() async {
        mockAIRepo.mockResult = createMockAIAnalysis(winnerBarcode: "111")
        
        await sut.fetchAIAnalysis()
        
        XCTAssertTrue(sut.isWinner(product: sut.productA))
        XCTAssertFalse(sut.isWinner(product: sut.productB))
    }
    
    func test_isWinner_whenNoAIResult_shouldReturnFalse() {
        XCTAssertFalse(sut.isWinner(product: sut.productA))
        XCTAssertFalse(sut.isWinner(product: sut.productB))
    }
    
    func test_displayName_whenProductHasName_shouldReturnName() {
        XCTAssertEqual(sut.displayName(for: sut.productA), "Apple")
    }
    
    func test_displayName_whenProductNameIsNil_shouldReturnUnknownKey() {
        let product = createMockProduct(barcode: "333", name: nil)
        
        XCTAssertEqual(sut.displayName(for: product), "common_unknown")
    }
    
    func test_primaryBrand_whenProductHasMultipleBrands_shouldReturnFirstBrand() {
        let product = createMockProduct(
            barcode: "333",
            name: "Test",
            brands: "First Brand, Second Brand"
        )
        
        XCTAssertEqual(sut.primaryBrand(for: product), "First Brand")
    }
    
    func test_primaryBrand_whenBrandsAreNil_shouldReturnEmptyString() {
        let product = createMockProduct(
            barcode: "333",
            name: "Test",
            brands: nil
        )
        
        XCTAssertEqual(sut.primaryBrand(for: product), "")
    }
    
    func test_formattedGrade_whenGradeExists_shouldReturnUppercasedGrade() {
        XCTAssertEqual(sut.formattedGrade(for: sut.productA, path: \.nutriscoreGrade), "A")
    }
    
    func test_formattedGrade_whenGradeIsNil_shouldReturnDash() {
        let product = createMockProduct(
            barcode: "333",
            name: "Test",
            nutriScore: nil
        )
        
        XCTAssertEqual(sut.formattedGrade(for: product, path: \.nutriscoreGrade), "-")
    }
    
    func test_getNutrientData_whenLowerIsBetterAndProductAIsLower_shouldMarkProductAAsBetter() {
        let result = sut.getNutrientData(
            path: \.sugars100g,
            suffix: "g",
            lowerIsBetter: true
        )
        
        XCTAssertEqual(result.valA, "5.0 g")
        XCTAssertEqual(result.valB, "12.0 g")
        XCTAssertEqual(result.resA, .better)
        XCTAssertEqual(result.resB, .worse)
    }
    
    func test_getNutrientData_whenHigherIsBetterAndProductAIsHigher_shouldMarkProductAAsBetter() {
        let result = sut.getNutrientData(
            path: \.proteins100g,
            suffix: "g",
            lowerIsBetter: false
        )
        
        XCTAssertEqual(result.valA, "3.0 g")
        XCTAssertEqual(result.valB, "1.0 g")
        XCTAssertEqual(result.resA, .better)
        XCTAssertEqual(result.resB, .worse)
    }
    
    func test_getNutrientData_whenValuesAreEqual_shouldMarkBothAsEqual() {
        sut.productA = createMockProduct(
            barcode: "111",
            name: "A",
            nutriments: createMockNutriments(kcal: 42)
        )
        sut.productB = createMockProduct(
            barcode: "222",
            name: "B",
            nutriments: createMockNutriments(kcal: 42)
        )
        
        let result = sut.getNutrientData(
            path: \.energyKcal100g,
            suffix: "kcal",
            lowerIsBetter: true
        )
        
        XCTAssertEqual(result.valA, "42.0 kcal")
        XCTAssertEqual(result.valB, "42.0 kcal")
        XCTAssertEqual(result.resA, .equal)
        XCTAssertEqual(result.resB, .equal)
    }
    
    func test_getNutrientData_whenProductAValueIsMissing_shouldReturnUnknown() {
        sut.productA = createMockProduct(
            barcode: "111",
            name: "A",
            nutriments: createMockNutriments(kcal: nil)
        )
        sut.productB = createMockProduct(
            barcode: "222",
            name: "B",
            nutriments: createMockNutriments(kcal: 42)
        )
        
        let result = sut.getNutrientData(
            path: \.energyKcal100g,
            suffix: "kcal",
            lowerIsBetter: true
        )
        
        XCTAssertEqual(result.valA, "-")
        XCTAssertEqual(result.valB, "42.0 kcal")
        XCTAssertEqual(result.resA, .unknown)
        XCTAssertEqual(result.resB, .unknown)
    }
    
    func test_getNutrientData_whenBothProductsHaveNoNutriments_shouldReturnUnknown() {
        sut.productA = createMockProduct(
            barcode: "111",
            name: "A",
            nutriments: nil
        )
        sut.productB = createMockProduct(
            barcode: "222",
            name: "B",
            nutriments: nil
        )
        
        let result = sut.getNutrientData(
            path: \.energyKcal100g,
            suffix: "kcal",
            lowerIsBetter: true
        )
        
        XCTAssertEqual(result.valA, "-")
        XCTAssertEqual(result.valB, "-")
        XCTAssertEqual(result.resA, .unknown)
        XCTAssertEqual(result.resB, .unknown)
    }
    
    private func createMockAIAnalysis(winnerBarcode: String) -> AIComparisonAnalysis {
        AIComparisonAnalysis(
            comparisonEn: "English analysis",
            comparisonUa: "Український аналіз",
            winnerBarcode: winnerBarcode,
            keyDifferencesEn: ["Less sugar", "Better ingredients"],
            keyDifferencesUa: ["Менше цукру", "Кращий склад"]
        )
    }
    
    private func createMockProduct(
        barcode: String,
        name: String?,
        brands: String? = nil,
        nutriScore: String? = nil,
        ecoScore: String? = nil,
        nutriments: Nutriments? = nil
    ) -> Product {
        Product(
            barcode: barcode,
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
            packagingEn: nil,
            packagingUa: nil,
            nutriscoreGrade: nutriScore,
            ecoscoreGrade: ecoScore,
            novaGroup: nil,
            nutriments: nutriments
        )
    }
    
    private func createMockNutriments(
        kcal: Double? = nil,
        proteins: Double? = nil,
        fat: Double? = nil,
        saturatedFat: Double? = nil,
        carbs: Double? = nil,
        sugars: Double? = nil,
        salt: Double? = nil
    ) -> Nutriments {
        Nutriments(
            addedSugars100g: nil,
            proteins100g: proteins,
            energyKcal100g: kcal,
            fat100g: fat,
            salt100g: salt,
            sugars100g: sugars,
            saturatedFat100g: saturatedFat,
            carbohydrates100g: carbs,
            caffeine100g: nil,
            addedSugarsServing: nil,
            proteinsServing: nil,
            energyKcalServing: nil,
            fatServing: nil,
            saltServing: nil,
            sugarsServing: nil,
            saturatedFatServing: nil,
            carbohydratesServing: nil,
            caffeineServing: nil
        )
    }
}
