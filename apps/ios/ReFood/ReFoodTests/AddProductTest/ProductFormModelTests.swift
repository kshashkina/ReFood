import XCTest
@testable import ReFood

final class ProductFormModelTests: XCTestCase {

    func test_canSave_emptyForm_isFalse() {
        let sut = ProductFormModel()
        XCTAssertFalse(sut.canSave(isEditing: false, isImageValid: true))
    }

    func test_canSave_newProduct_noImage_isFalse() {
        var sut = ProductFormModel()
        fillValidData(into: &sut)
        
        XCTAssertFalse(sut.canSave(isEditing: false, isImageValid: false), "Photo is required for new products")
    }

    func test_canSave_newProduct_withImage_isTrue() {
        var sut = ProductFormModel()
        fillValidData(into: &sut)
        
        XCTAssertTrue(sut.canSave(isEditing: false, isImageValid: true))
    }

    func test_canSave_editingProduct_noImage_isTrue() {
        var sut = ProductFormModel()
        fillValidData(into: &sut)
        
        XCTAssertTrue(sut.canSave(isEditing: true, isImageValid: false), "New photo is optional during editing")
    }

    func test_toProductRequest_parsesNumbersWithCommasCorrectly() {
        var sut = ProductFormModel()
        sut.nutrition.kcal = "150,5"
        sut.nutrition.proteins = "10.2"
        
        let request = sut.toProductRequest(barcode: "123")
        
        XCTAssertEqual(request.nutriments.energy_kcal_100g, 150.5, "Should correctly convert comma to dot")
        XCTAssertEqual(request.nutriments.proteins_100g, 10.2, "Should parse dot correctly")
    }
    
    func test_toProductRequest_ignoresEmptyPackagingItems() {
        var sut = ProductFormModel()
        sut.packaging = [
            PackagingInput(shape: "Box", material: "Paper", recycling: "PAP 20"),
            PackagingInput(shape: "", material: "", recycling: "")
        ]
        
        let request = sut.toProductRequest(barcode: "123")
        
        XCTAssertEqual(request.packaging.count, 1, "Empty packaging items should not be sent to server")
    }

    private func fillValidData(into form: inout ProductFormModel) {
        form.name = "Test"
        form.brand = "Test"
        form.ingredients = "Test"
        form.nutrition.kcal = "1"
        form.nutrition.proteins = "1"
        form.nutrition.fats = "1"
        form.nutrition.carbs = "1"
    }
}
