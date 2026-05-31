import SwiftUI
import Combine

@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var form: ProductFormModel
    
    @Published var selectedUIImage: UIImage? = nil {
        didSet { if let image = selectedUIImage { processImageUpload(image) } }
    }
    
    @Published var isUploadingImage = false
    @Published var isImageValid = false
    @Published var imageError: String? = nil
    @Published var isSaving = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    
    private var s3Key: String = ""
    private var imageId: String = ""
    
    let barcode: String
    let isEditingMode: Bool
    let existingImageUrl: String?
    let grades = ["A", "B", "C", "D", "E"]
    
    private let repository: ProductRepository
    private let uploadService: ImageUploadServicing
    private let metricsRepository: MetricsRepositoryProtocol
    
    init(
        barcode: String,
        existingProduct: Product? = nil,
        repository: ProductRepository,
        uploadService: ImageUploadServicing,
        metricsRepository: MetricsRepositoryProtocol
    ) {
        self.barcode = barcode
        self.repository = repository
        self.uploadService = uploadService
        self.metricsRepository = metricsRepository
        
        if let p = existingProduct {
            self.isEditingMode = true
            self.existingImageUrl = p.imageUrl
            self.form = ProductFormModel(from: p) 
        } else {
            self.isEditingMode = false
            self.existingImageUrl = nil
            self.form = ProductFormModel()
        }
    }

    var canSave: Bool {
        form.canSave(isEditing: isEditingMode, isImageValid: isImageValid && !isUploadingImage)
    }

    func processImageUpload(_ image: UIImage) {
        isUploadingImage = true
        isImageValid = false
        imageError = nil
        
        Task {
            do {
                let result = try await uploadService.uploadAndValidate(image: image)
                
                self.s3Key = result.s3Key
                self.imageId = result.imageId
                self.isImageValid = result.isValid
                
                if !result.isValid {
                    self.imageError = result.errorMessage ?? "AI: Invalid image"
                }
            } catch {
                self.imageError = "Upload failed: \(error.localizedDescription)"
            }
            isUploadingImage = false
        }
    }

    func saveProduct() async {
        guard canSave else { return }
        isSaving = true
        error = nil
        
        var productRequest = form.toProductRequest(barcode: barcode)
        
        do {
            if isEditingMode && selectedUIImage == nil {
                productRequest.image_url = existingImageUrl
                try await repository.addProduct(productRequest)
            } else {
                productRequest.imageId = self.imageId
                productRequest.s3Key = self.s3Key
                try await repository.addProduct(productRequest)
            }
            metricsRepository.trackProductAdded()
            isSuccess = true
        } catch {
            self.error = "Saving failed: \(error.localizedDescription)"
        }
        isSaving = false
    }
    
    func addPackagingField() {
        form.packaging.append(PackagingInput())
    }
}
