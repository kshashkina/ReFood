import Foundation

final class ProductRepositoryImpl: ProductRepository {

    func getProduct(byBarcode barcode: String) async throws -> Product {
        do {
            let data = try await ProductAPI.fetchProductData(barcode: barcode)
            let decoder = JSONDecoder()
            let response = try decoder.decode(ProductResponse.self, from: data)
            var finalProduct = response.product
            finalProduct.barcode = barcode
            return finalProduct

        } catch let error as NetworkError {
            if case let .httpStatus(code, _) = error, code == 404 {
                throw ProductError.notFound
            }
            throw ProductError.network

        } catch is DecodingError {
            throw ProductError.invalidData

        } catch {
            throw ProductError.unknown
        }
    }
    
    func recordScan(product: Product) async throws {
        let payload = ScanPayload(
            barcode: product.barcode,
            productName: product.productName ?? "",
            productBrand: product.brands ?? "",
            image: product.imageUrl ?? "",
            productVersion: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        do {
            try await ProductAPI.recordScan(payload: payload)
        } catch {
            print("⚠️ Failed to record scan: \(error)")
            throw ProductError.network
        }
    }
    
    func addProduct(_ product: ProductAdd) async throws {
            do {
                try await ProductAPI.addProduct(product: product)
            } catch let error as NetworkError {
                throw error
            } catch {
                throw ProductError.unknown
            }
        }
    
    func prepareUpload() async throws -> S3UploadResponse {
            try await ProductAPI.getUploadUrl()
        }

    func uploadImage(url: String, data: Data) async throws {
            try await ProductAPI.uploadToS3(urlString: url, imageData: data)
        }

    func checkValidation(imageId: String) async throws -> S3ValidationResponse {
        try await ProductAPI.checkImageValidationStatus(imageId: imageId)
    }
    
    func toggleFavorite(barcode: String, isFavorite: Bool) async throws {
            if isFavorite {
                try await ProductAPI.addFavorite(barcode: barcode)
            } else {
                try await ProductAPI.removeFavorite(barcode: barcode)
            }
        }
}
