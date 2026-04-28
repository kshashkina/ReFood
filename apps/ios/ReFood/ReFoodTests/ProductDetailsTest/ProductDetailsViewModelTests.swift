import XCTest
@testable import ReFood

@MainActor
final class ProductDetailsViewModelTests: XCTestCase {
    
    var sut: ProductDetailsViewModel!
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
    
    func test_displayName_whenProductHasName_shouldReturnName() {
        sut = makeSUT(product: createMockProduct(productName: "Apple"))
        XCTAssertEqual(sut.displayName, "Apple")
    }
    
    func test_displayName_whenProductNameIsNil_shouldReturnLocalizedUnknown() {
        sut = makeSUT(product: createMockProduct(productName: nil))
        XCTAssertEqual(sut.displayName, String(localized: "common_unknown"))
    }
    
    func test_brand_whenProductHasBrand_shouldReturnBrand() {
        sut = makeSUT(product: createMockProduct(brands: "Test Brand"))
        XCTAssertEqual(sut.brand, "Test Brand")
    }
    
    func test_categoriesLine_whenLanguageIsEnglish_shouldReturnEnglishCategories() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            categoriesTagsEn: ["Snacks", "Sweet"],
            categoriesTagsUa: ["Снеки", "Солодке"]
        ))
        
        XCTAssertEqual(sut.categoriesLine, "Snacks, Sweet")
    }
    
    func test_categoriesLine_whenLanguageIsUkrainian_shouldReturnUkrainianCategories() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            categoriesTagsEn: ["Snacks", "Sweet"],
            categoriesTagsUa: ["Снеки", "Солодке"]
        ))
        
        XCTAssertEqual(sut.categoriesLine, "Снеки, Солодке")
    }
    
    func test_categoriesLine_whenCategoriesAreEmpty_shouldReturnNil() {
        sut = makeSUT(product: createMockProduct(categoriesTagsEn: []))
        XCTAssertNil(sut.categoriesLine)
    }
    
    func test_aiAnalysis_whenLanguageIsEnglish_shouldReturnEnglishAnalysis() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            analysisEn: "English analysis",
            analysisUa: "Український аналіз"
        ))
        
        XCTAssertEqual(sut.aiAnalysis, "English analysis")
    }
    
    func test_aiAnalysis_whenLanguageIsUkrainian_shouldReturnUkrainianAnalysis() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            analysisEn: "English analysis",
            analysisUa: "Український аналіз"
        ))
        
        XCTAssertEqual(sut.aiAnalysis, "Український аналіз")
    }
    
    func test_ingredientsList_whenLanguageIsEnglish_shouldReturnEnglishIngredients() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            ingredientsEn: ["Sugar", "Milk"],
            ingredientsUa: ["Цукор", "Молоко"]
        ))
        
        XCTAssertEqual(sut.ingredientsList, ["Sugar", "Milk"])
    }
    
    func test_ingredientsList_whenLanguageIsUkrainian_shouldReturnUkrainianIngredients() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            ingredientsEn: ["Sugar", "Milk"],
            ingredientsUa: ["Цукор", "Молоко"]
        ))
        
        XCTAssertEqual(sut.ingredientsList, ["Цукор", "Молоко"])
    }
    
    func test_allergensList_whenLanguageIsEnglish_shouldReturnEnglishAllergens() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            allergensEn: ["Milk", "Nuts"],
            allergensUa: ["Молоко", "Горіхи"]
        ))
        
        XCTAssertEqual(sut.allergensList, ["Milk", "Nuts"])
    }
    
    func test_allergensList_whenLanguageIsUkrainian_shouldReturnUkrainianAllergens() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            allergensEn: ["Milk", "Nuts"],
            allergensUa: ["Молоко", "Горіхи"]
        ))
        
        XCTAssertEqual(sut.allergensList, ["Молоко", "Горіхи"])
    }
    
    func test_packagingItems_whenLanguageIsEnglish_shouldReturnEnglishPackaging() {
        mockLanguageProvider.currentLanguageCode = "en"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ],
            packagingUa: [
                createMockPackagingItem(shape: "пляшка", material: "пластик")
            ]
        ))
        
        XCTAssertEqual(sut.packagingItems.count, 1)
        XCTAssertEqual(sut.packagingItems.first?.title, "Bottle")
        XCTAssertEqual(sut.packagingItems.first?.subtitle, "Plastic")
    }
    
    func test_packagingItems_whenLanguageIsUkrainian_shouldReturnUkrainianPackaging() {
        mockLanguageProvider.currentLanguageCode = "ua"
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: "bottle", material: "plastic")
            ],
            packagingUa: [
                createMockPackagingItem(shape: "пляшка", material: "пластик")
            ]
        ))
        
        XCTAssertEqual(sut.packagingItems.count, 1)
        XCTAssertEqual(sut.packagingItems.first?.title, "Пляшка")
        XCTAssertEqual(sut.packagingItems.first?.subtitle, "Пластик")
    }
    
    func test_packagingItems_whenShapeIsNil_shouldReturnLocalizedFallbackTitle() {
        sut = makeSUT(product: createMockProduct(
            packagingEn: [
                createMockPackagingItem(shape: nil, material: "plastic")
            ]
        ))
        
        XCTAssertEqual(sut.packagingItems.first?.title, String(localized: "recycling_packaging_element"))
        XCTAssertEqual(sut.packagingItems.first?.subtitle, "Plastic")
    }
    
    func test_nutriScoreGrade_whenGradeExists_shouldReturnUppercasedGrade() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "a"))
        XCTAssertEqual(sut.nutriScoreGrade, "A")
    }
    
    func test_nutriScoreGrade_whenGradeIsNil_shouldReturnDash() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: nil))
        XCTAssertEqual(sut.nutriScoreGrade, "-")
    }
    
    func test_ecoScoreGrade_whenGradeExists_shouldReturnUppercasedGrade() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "b"))
        XCTAssertEqual(sut.ecoScoreGrade, "B")
    }
    
    func test_ecoScoreGrade_whenGradeIsNil_shouldReturnDash() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: nil))
        XCTAssertEqual(sut.ecoScoreGrade, "-")
    }
    
    func test_nutriSubtitleKey_shouldReturnExcellentForGradeA() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "a"))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_excellent")
    }
    
    func test_nutriSubtitleKey_shouldReturnGoodForGradeB() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "b"))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_good")
    }
    
    func test_nutriSubtitleKey_shouldReturnAverageForGradeC() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "c"))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_average")
    }
    
    func test_nutriSubtitleKey_shouldReturnNotGreatForGradeD() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "d"))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_not_great")
    }
    
    func test_nutriSubtitleKey_shouldReturnPoorForGradeE() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: "e"))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_poor")
    }
    
    func test_nutriSubtitleKey_shouldReturnUnknownWhenGradeIsNil() {
        sut = makeSUT(product: createMockProduct(nutriscoreGrade: nil))
        XCTAssertEqual(sut.nutriSubtitleKey, "grade_unknown")
    }
    
    func test_ecoSubtitleKey_shouldReturnEcoFriendlyForGradeA() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "a"))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_eco_friendly")
    }
    
    func test_ecoSubtitleKey_shouldReturnEcoFriendlyForGradeB() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "b"))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_eco_friendly")
    }
    
    func test_ecoSubtitleKey_shouldReturnModerateForGradeC() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "c"))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_moderate")
    }
    
    func test_ecoSubtitleKey_shouldReturnLowForGradeD() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "d"))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_low")
    }
    
    func test_ecoSubtitleKey_shouldReturnLowForGradeE() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: "e"))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_low")
    }
    
    func test_ecoSubtitleKey_shouldReturnUnknownWhenGradeIsNil() {
        sut = makeSUT(product: createMockProduct(ecoscoreGrade: nil))
        XCTAssertEqual(sut.ecoSubtitleKey, "grade_unknown")
    }
    
    func test_caloriesString_whenNutritionTabIsPer100g_shouldReturnPer100gCalories() {
        sut = makeSUT(product: createMockProduct(
            nutriments: createMockNutriments(
                energyKcal100g: 42,
                energyKcalServing: 100
            )
        ))
        sut.nutritionTab = .per100g
        
        XCTAssertEqual(sut.caloriesString(), "42 kcal")
    }
    
    func test_caloriesString_whenNutritionTabIsServing_shouldReturnServingCalories() {
        sut = makeSUT(product: createMockProduct(
            nutriments: createMockNutriments(
                energyKcal100g: 42,
                energyKcalServing: 100
            )
        ))
        sut.nutritionTab = .perServing
        
        XCTAssertEqual(sut.caloriesString(), "100 kcal")
    }
    
    func test_caloriesString_whenValueIsNil_shouldReturnDash() {
        sut = makeSUT(product: createMockProduct(nutriments: createMockNutriments()))
        XCTAssertEqual(sut.caloriesString(), "—")
    }
    
    func test_gramsString_whenNutritionTabIsPer100g_shouldReturnPer100gValue() {
        sut = makeSUT(product: createMockProduct(
            nutriments: createMockNutriments(
                proteins100g: 3.5,
                proteinsServing: 7
            )
        ))
        sut.nutritionTab = .per100g
        
        let result = sut.gramsString(for: \.proteins100g, serving: \.proteinsServing)
        
        XCTAssertEqual(result, "3.5 g")
    }
    
    func test_gramsString_whenNutritionTabIsServing_shouldReturnServingValue() {
        sut = makeSUT(product: createMockProduct(
            nutriments: createMockNutriments(
                proteins100g: 3.5,
                proteinsServing: 7
            )
        ))
        sut.nutritionTab = .perServing
        
        let result = sut.gramsString(for: \.proteins100g, serving: \.proteinsServing)
        
        XCTAssertEqual(result, "7 g")
    }
    
    func test_gramsString_whenValueIsNil_shouldReturnDash() {
        sut = makeSUT(product: createMockProduct(nutriments: createMockNutriments()))
        
        let result = sut.gramsString(for: \.proteins100g, serving: \.proteinsServing)
        
        XCTAssertEqual(result, "—")
    }
    
    private func makeSUT(product: Product) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            product: product,
            languageProvider: mockLanguageProvider
        )
    }
    
    private func createMockProduct(
        productName: String? = "Test Product",
        brands: String? = "Test Brand",
        analysisEn: String? = nil,
        analysisUa: String? = nil,
        categoriesTagsEn: [String]? = nil,
        categoriesTagsUa: [String]? = nil,
        ingredientsEn: [String]? = nil,
        ingredientsUa: [String]? = nil,
        allergensEn: [String]? = nil,
        allergensUa: [String]? = nil,
        packagingEn: [PackagingItem]? = nil,
        packagingUa: [PackagingItem]? = nil,
        nutriscoreGrade: String? = nil,
        ecoscoreGrade: String? = nil,
        nutriments: Nutriments? = nil
    ) -> Product {
        Product(
            barcode: "1234567890123",
            productName: productName,
            brands: brands,
            quantity: nil,
            imageUrl: nil,
            analysisEn: analysisEn,
            analysisUa: analysisUa,
            categoriesTagsEn: categoriesTagsEn,
            categoriesTagsUa: categoriesTagsUa,
            ingredientsEn: ingredientsEn,
            ingredientsUa: ingredientsUa,
            allergensEn: allergensEn,
            allergensUa: allergensUa,
            packagingEn: packagingEn,
            packagingUa: packagingUa,
            nutriscoreGrade: nutriscoreGrade,
            ecoscoreGrade: ecoscoreGrade,
            novaGroup: nil,
            nutriments: nutriments
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
    
    private func createMockNutriments(
        addedSugars100g: Double? = nil,
        proteins100g: Double? = nil,
        energyKcal100g: Double? = nil,
        fat100g: Double? = nil,
        salt100g: Double? = nil,
        sugars100g: Double? = nil,
        saturatedFat100g: Double? = nil,
        carbohydrates100g: Double? = nil,
        caffeine100g: Double? = nil,
        addedSugarsServing: Double? = nil,
        proteinsServing: Double? = nil,
        energyKcalServing: Double? = nil,
        fatServing: Double? = nil,
        saltServing: Double? = nil,
        sugarsServing: Double? = nil,
        saturatedFatServing: Double? = nil,
        carbohydratesServing: Double? = nil,
        caffeineServing: Double? = nil
    ) -> Nutriments {
        Nutriments(
            addedSugars100g: addedSugars100g,
            proteins100g: proteins100g,
            energyKcal100g: energyKcal100g,
            fat100g: fat100g,
            salt100g: salt100g,
            sugars100g: sugars100g,
            saturatedFat100g: saturatedFat100g,
            carbohydrates100g: carbohydrates100g,
            caffeine100g: caffeine100g,
            addedSugarsServing: addedSugarsServing,
            proteinsServing: proteinsServing,
            energyKcalServing: energyKcalServing,
            fatServing: fatServing,
            saltServing: saltServing,
            sugarsServing: sugarsServing,
            saturatedFatServing: saturatedFatServing,
            carbohydratesServing: carbohydratesServing,
            caffeineServing: caffeineServing
        )
    }
}
