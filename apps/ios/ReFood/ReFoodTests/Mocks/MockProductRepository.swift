import Foundation
import UIKit
@testable import ReFood

final class MockProductRepository: ProductRepository {
    
    var shouldReturnError = false
    var isAddProductCalled = false
    var finalizeAndAddCalled = false

    func getProduct(byBarcode barcode: String) async throws -> Product {
        fatalError("Not used in this context")
    }

    func addProduct(_ product: ProductAdd) async throws {
        if shouldReturnError {
            throw ProductError.unknown
        }
        isAddProductCalled = true
    }

    func prepareUpload() async throws -> S3UploadResponse {
        return S3UploadResponse(
            uploadUrl: "test_url",
            imageId: "test_id",
            s3Key: "test_key"
        )
    }

    func uploadImage(url: String, data: Data) async throws {
    }

    func validateImage(s3Key: String, imageId: String) async throws -> S3ValidationResponse {
        return S3ValidationResponse(
            isValid: true,
            detectedObject: "food",
            error_ua: nil,
            error_en: nil
        )
    }

    func finalizeAndAdd(product: ProductAdd, s3Key: String, imageId: String) async throws {
        if shouldReturnError {
            throw ProductError.unknown
        }
        finalizeAndAddCalled = true
    }
}
