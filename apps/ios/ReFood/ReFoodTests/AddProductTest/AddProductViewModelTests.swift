import XCTest
@testable import ReFood

@MainActor
final class AddProductViewModelTests: XCTestCase {
    
    var sut: AddProductViewModel!
    var mockRepo: MockProductRepository!
    var mockUploadService: MockImageUploadService!
    var mockMetricsRepo: MockMetricsRepository!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockProductRepository()
        mockUploadService = MockImageUploadService()
        mockMetricsRepo = MockMetricsRepository()
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        mockUploadService = nil
        mockMetricsRepo = nil
        super.tearDown()
    }

    func test_init_withNoExistingProduct_setsEditingModeFalse() {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        
        XCTAssertFalse(sut.isEditingMode)
        XCTAssertNil(sut.existingImageUrl)
        XCTAssertTrue(sut.form.name.isEmpty, "Form should be empty for a new product")
    }

    func test_processImageUpload_success_updatesImageValidationState() async {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        let dummyImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        sut.processImageUpload(dummyImage)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(mockUploadService.uploadAndValidateCalled)
        XCTAssertTrue(sut.isImageValid)
        XCTAssertNil(sut.imageError)
        XCTAssertFalse(sut.isUploadingImage)
    }

    func test_processImageUpload_invalidImage_setsImageError() async {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        mockUploadService.shouldReturnInvalidImage = true
        mockUploadService.customErrorMessage = "Please scan food."
        
        sut.processImageUpload(UIImage())
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(sut.isImageValid)
        XCTAssertEqual(sut.imageError, "Please scan food.")
    }

    func test_saveProduct_whenFormInvalid_doesNotCallRepository() async {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        
        await sut.saveProduct()
        
        XCTAssertFalse(mockRepo.isAddProductCalled)
        XCTAssertFalse(mockMetricsRepo.trackProductAddedCalled)
    }

    func test_saveProduct_newProduct_callsAddProduct() async {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        makeFormValid(for: sut)
        sut.isImageValid = true
        
        await sut.saveProduct()
        
        XCTAssertTrue(mockRepo.isAddProductCalled, "Should call addProduct for new products")
        XCTAssertTrue(sut.isSuccess)
        XCTAssertTrue(mockMetricsRepo.trackProductAddedCalled, "Should track product added metric")
    }

    func test_addPackagingField_appendsNewItemToForm() {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        let initialCount = sut.form.packaging.count
        
        sut.addPackagingField()
        
        XCTAssertEqual(sut.form.packaging.count, initialCount + 1, "Should add a new empty packaging field")
    }
    
    func test_saveProduct_whenErrorOccurs_resetsIsSavingToFalse() async {
        sut = AddProductViewModel(barcode: "123", repository: mockRepo, uploadService: mockUploadService, metricsRepository: mockMetricsRepo)
        makeFormValid(for: sut)
        sut.isImageValid = true
        
        mockRepo.shouldReturnError = true
        
        await sut.saveProduct()
        
        XCTAssertNotNil(sut.error, "Error should be recorded")
        XCTAssertFalse(sut.isSaving, "isSaving should reset to false to unlock the UI")
        XCTAssertFalse(sut.isSuccess, "isSuccess should remain false")
        XCTAssertFalse(mockMetricsRepo.trackProductAddedCalled, "Metric should not be tracked on error")
    }

    private func makeFormValid(for vm: AddProductViewModel) {
        vm.form.name = "Test"
        vm.form.brand = "Test"
        vm.form.ingredients = "Test"
        vm.form.nutrition.kcal = "1"
        vm.form.nutrition.proteins = "1"
        vm.form.nutrition.fats = "1"
        vm.form.nutrition.carbs = "1"
    }
}
