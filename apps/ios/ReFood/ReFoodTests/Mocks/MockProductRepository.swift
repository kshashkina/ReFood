import Foundation
import UIKit
@testable import ReFood

final class MockProductRepository: ProductRepository {
    
    var shouldReturnError = false
    
    var isAddProductCalled = false
    var recordScanCalled = false
    var prepareUploadCalled = false
    var uploadImageCalled = false
    var checkValidationCalled = false
    var toggleFavoriteCalled = false
    
    var mockProduct: Product?
    var mockValidationResponse: S3ValidationResponse?

    func getProduct(byBarcode barcode: String) async throws -> Product {
        if shouldReturnError {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
        }
        
        if let product = mockProduct {
            return product
        } else {
            fatalError("Please add mock product to the test!")
        }
    }
    
    func recordScan(product: Product) async throws {
        if shouldReturnError {
            throw ProductError.network
        }
        recordScanCalled = true
    }

    func addProduct(_ product: ProductAdd) async throws {
        if shouldReturnError {
            throw ProductError.unknown
        }
        isAddProductCalled = true
    }

    func prepareUpload() async throws -> S3UploadResponse {
        if shouldReturnError {
            throw ProductError.unknown
        }
        prepareUploadCalled = true
        return S3UploadResponse(
            uploadUrl: "test_url",
            imageId: "test_id",
            s3Key: "test_key",
            expiresIn: 3600
        )
    }

    func uploadImage(url: String, data: Data) async throws {
        if shouldReturnError {
            throw ProductError.unknown
        }
        uploadImageCalled = true
    }

    func checkValidation(imageId: String) async throws -> S3ValidationResponse {
        if shouldReturnError {
            throw ProductError.unknown
        }
        checkValidationCalled = true
        
        if let response = mockValidationResponse {
            return response
        }
        
        return S3ValidationResponse(
            status: "valid",
            error_ua: nil,
            error_en: nil
        )
    }
    
    func toggleFavorite(barcode: String, isFavorite: Bool) async throws {
        if shouldReturnError {
            throw ProductError.unknown
        }
        toggleFavoriteCalled = true
    }
}
