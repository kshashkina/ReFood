import Foundation

public protocol ProductRepository {
    func getProduct(byBarcode barcode: String) async throws -> Product
    func addProduct(_ product: ProductAdd) async throws
    func prepareUpload() async throws -> S3UploadResponse
    func uploadImage(url: String, data: Data) async throws
    func validateImage(s3Key: String, imageId: String) async throws -> S3ValidationResponse
    func finalizeAndAdd(product: ProductAdd, s3Key: String, imageId: String) async throws
}
