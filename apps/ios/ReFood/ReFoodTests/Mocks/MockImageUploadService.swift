import Foundation
import UIKit
@testable import ReFood

final class MockImageUploadService: ImageUploadServicing {
    var shouldReturnError = false
    var shouldReturnInvalidImage = false
    var customErrorMessage: String?
    
    var uploadAndValidateCalled = false
    
    func uploadAndValidate(image: UIImage) async throws -> (s3Key: String, imageId: String, isValid: Bool, errorMessage: String?) {
        uploadAndValidateCalled = true
        
        if shouldReturnError {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload Error"])
        }
        
        if shouldReturnInvalidImage {
            return ("testKey", "testId", false, customErrorMessage ?? "Not a food item")
        }
        
        return ("testKey", "testId", true, nil)
    }
}
