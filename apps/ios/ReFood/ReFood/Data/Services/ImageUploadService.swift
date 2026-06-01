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
        while true {
            let validation = try await repository.checkValidation(imageId: uploadInfo.imageId)
            
            if validation.status == "APPROVED" {
                return (uploadInfo.s3Key, uploadInfo.imageId, true, nil)
            } else if validation.status == "REJECTED" {
                let languageCode = Locale.current.language.languageCode?.identifier
                let localizedError = languageCode == "uk" ? validation.error_ua : validation.error_en
                return (uploadInfo.s3Key, uploadInfo.imageId, false, localizedError)
            }
            
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}
