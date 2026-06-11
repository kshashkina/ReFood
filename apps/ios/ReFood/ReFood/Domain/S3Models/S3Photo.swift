import Foundation

public struct S3UploadResponse: Decodable {
    let uploadUrl: String
    let imageId: String
    let s3Key: String
    let expiresIn: Int?
}

public struct S3ValidationResponse: Decodable {
    let status: String
    let error_ua: String?
    let error_en: String?
}
