import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(code: Int, body: String?)
    case decodingFailed
}
