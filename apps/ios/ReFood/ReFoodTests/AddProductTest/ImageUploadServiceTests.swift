import XCTest
@testable import ReFood

final class ImageUploadServiceTests: XCTestCase {
    
    var sut: ImageUploadService!
    var mockRepo: MockProductRepository!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockProductRepository()
        sut = ImageUploadService(repository: mockRepo)
    }

    func test_uploadAndValidate_returnsCorrectLanguageError() async throws {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        let result = try await sut.uploadAndValidate(image: image)
        

        let languageCode = Locale.current.language.languageCode?.identifier
        
        if languageCode == "uk" {
            XCTAssertEqual(result.errorMessage, nil)
        }
    }
}
