import Foundation

enum ProductAPI {

    static func fetchProductData(barcode: String) async throws -> Data {
        let url = APIConfig.baseURL.appendingPathComponent("product").appendingPathComponent(barcode)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

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
            let url = APIConfig.baseURL.appendingPathComponent("s3-bucket/upload-url")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw NetworkError.invalidResponse
            }
            return try JSONDecoder().decode(S3UploadResponse.self, from: data)
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


    static func validateImage(s3Key: String, imageId: String) async throws -> S3ValidationResponse {
            let url = APIConfig.baseURL.appendingPathComponent("s3-bucket/validate")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["s3Key": s3Key, "imageId": imageId]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(S3ValidationResponse.self, from: data)
        }

    static func finalizeImage(s3Key: String, imageId: String, barcode: String) async throws -> String {
            let url = APIConfig.baseURL.appendingPathComponent("s3-bucket/finalize")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["s3Key": s3Key, "imageId": imageId, "barcode": barcode]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let (data, _) = try await URLSession.shared.data(for: request)
            let res = try JSONDecoder().decode(S3FinalizeResponse.self, from: data)
            return res.publicUrl
        }
}
