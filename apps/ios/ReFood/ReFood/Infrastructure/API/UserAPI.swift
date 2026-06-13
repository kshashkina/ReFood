import Foundation
import Amplify
import AWSAPIPlugin

enum UserAPI {

    private static let baseURL = APIConfig.baseURL
    
    static func registerUser(identityId: String, deviceId: String) async throws -> Data {
        try await NetworkRunner.execute {
            let body = try JSONEncoder().encode(["identityId": identityId, "deviceId": deviceId])
            let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/register", body: body)
            return try await Amplify.API.post(request: request)
        }
    }
    
    static func linkAccount(idToken: String, deviceId: String) async throws -> Data {
        try await NetworkRunner.execute {
            guard let url = URL(string: "\(baseURL)/users/register/link-account") else {
                throw NetworkError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["deviceId": deviceId])
            
            return try await performRequest(request)
        }
    }
    
    static func deleteUser(idToken: String) async throws -> Data {
        try await NetworkRunner.execute {
            guard let url = URL(string: "\(baseURL)/users") else {
                throw NetworkError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            
            return try await performRequest(request)
        }
    }
    
    private static func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let body = String(decoding: data, as: UTF8.self)
            throw NetworkError.httpStatus(code: httpResponse.statusCode, body: body)
        }
        
        return data
    }
}
