import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import AWSAPIPlugin


enum ProductAPI {

    static func fetchProductData(barcode: String) async throws -> Data {
        let url = APIConfig.baseURL.appendingPathComponent("product").appendingPathComponent(barcode)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        if let session = try? await Amplify.Auth.fetchAuthSession(),
           let cognitoProvider = session as? AuthCognitoTokensProvider,
           let tokens = try? cognitoProvider.getCognitoTokens().get() {
            request.setValue("Bearer \(tokens.idToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw NetworkError.httpStatus(code: http.statusCode, body: body)
        }

        return data
    }
    
    static func addProduct(product: ProductAdd) async throws {
            let url = APIConfig.baseURL.appendingPathComponent("product")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 20
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let session = try? await Amplify.Auth.fetchAuthSession(),
               let cognitoProvider = session as? AuthCognitoTokensProvider,
               let tokens = try? cognitoProvider.getCognitoTokens().get() {
                request.setValue("Bearer \(tokens.idToken)", forHTTPHeaderField: "Authorization")
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            request.httpBody = try encoder.encode(product)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8)
                throw NetworkError.httpStatus(code: http.statusCode, body: body)
            }
        }

    static func getUploadUrl() async throws -> S3UploadResponse {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/s3-bucket/upload-url")
        let data = try await Amplify.API.get(request: request)
        return try JSONDecoder().decode(S3UploadResponse.self, from: data)
    }

    static func checkImageValidationStatus(imageId: String) async throws -> S3ValidationResponse {
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/status-check/image-validation/\(imageId)")
        let data = try await Amplify.API.get(request: request)
        return try JSONDecoder().decode(S3ValidationResponse.self, from: data)
    }

    static func uploadToS3(urlString: String, imageData: Data) async throws {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidResponse }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
    }
    static func addFavorite(barcode: String) async throws {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product/\(barcode)/favorite")
            _ = try await Amplify.API.post(request: request)
        }

        static func removeFavorite(barcode: String) async throws {
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/product/\(barcode)/favorite")
            _ = try await Amplify.API.delete(request: request)
        }
}
