import UIKit

public protocol ImageUploadServicing {
    func uploadAndValidate(image: UIImage) async throws -> (s3Key: String, imageId: String, isValid: Bool, errorMessage: String?)
}

public final class ImageUploadService: ImageUploadServicing {
    private let repository: ProductRepository
    
    public init(repository: ProductRepository) {
        self.repository = repository
    }

    public func uploadAndValidate(image: UIImage) async throws -> (s3Key: String, imageId: String, isValid: Bool, errorMessage: String?) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ProductError.invalidData
        }
        
        let uploadInfo = try await repository.prepareUpload()
        try await repository.uploadImage(url: uploadInfo.uploadUrl, data: data)
        let validation = try await repository.validateImage(s3Key: uploadInfo.s3Key, imageId: uploadInfo.imageId)
        
        let localizedError: String?
        let languageCode = Locale.current.language.languageCode?.identifier
        
        if languageCode == "uk" {
            localizedError = validation.error_ua
        } else {
            localizedError = validation.error_en
        }
        
        return (uploadInfo.s3Key, uploadInfo.imageId, validation.isValid, localizedError)
    }
}
