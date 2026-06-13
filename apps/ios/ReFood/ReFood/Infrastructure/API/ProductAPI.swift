import Foundation
import Amplify
import AWSAPIPlugin

enum ProductAPI {

    static func fetchProductData(barcode: String) async throws -> Data {
        try await NetworkRunner.execute {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product/\(barcode)")
            do {
                return try await Amplify.API.get(request: request)
            } catch let error as APIError {
                if case let .httpStatusError(statusCode, _) = error {
                    throw NetworkError.httpStatus(code: statusCode, body: "")
                }
                throw NetworkError.invalidResponse
            } catch {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    static func recordScan(payload: ScanPayload) async throws {
        try await NetworkRunner.execute {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/scans", body: data)
            
            do {
                _ = try await Amplify.API.post(request: request)
            } catch let error as APIError {
                if case let .httpStatusError(statusCode, _) = error {
                    throw NetworkError.httpStatus(code: statusCode, body: "")
                }
                throw NetworkError.invalidResponse
            } catch {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    static func addProduct(product: ProductAdd) async throws {
        try await NetworkRunner.execute {
            let encoder = JSONEncoder()
            let data = try encoder.encode(product)
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product", body: data)
            
            do {
                _ = try await Amplify.API.post(request: request)
            } catch let error as APIError {
                if case let .httpStatusError(statusCode, _) = error {
                    throw NetworkError.httpStatus(code: statusCode, body: "")
                }
                throw NetworkError.invalidResponse
            } catch {
                throw NetworkError.invalidResponse
            }
        }
    }

    static func getUploadUrl() async throws -> S3UploadResponse {
        try await NetworkRunner.execute {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/s3-bucket/upload-url")
            let data = try await Amplify.API.get(request: request)
            return try JSONDecoder().decode(S3UploadResponse.self, from: data)
        }
    }

    static func checkImageValidationStatus(imageId: String) async throws -> S3ValidationResponse {
        try await NetworkRunner.execute {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/status-check/image-validation/\(imageId)")
            let data = try await Amplify.API.get(request: request)
            return try JSONDecoder().decode(S3ValidationResponse.self, from: data)
        }
    }

    static func uploadToS3(urlString: String, imageData: Data) async throws {
        try await NetworkRunner.execute {
            guard let url = URL(string: urlString) else { throw NetworkError.invalidResponse }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

            let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    static func addFavorite(barcode: String) async throws {
        try await NetworkRunner.execute {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product/\(barcode)/favorite")
            _ = try await Amplify.API.post(request: request)
        }
    }

    static func removeFavorite(barcode: String) async throws {
        try await NetworkRunner.execute {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product/\(barcode)/favorite")
            _ = try await Amplify.API.delete(request: request)
        }
    }
}
