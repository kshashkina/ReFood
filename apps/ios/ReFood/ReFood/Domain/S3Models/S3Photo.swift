public struct S3UploadResponse: Decodable {
    let uploadUrl: String
    let imageId: String
    let s3Key: String
}

public struct S3ValidationResponse: Decodable {
    let isValid: Bool
    let detectedObject: String?
    let error_ua: String?
    let error_en: String?
}

public struct S3FinalizeResponse: Decodable {
    let publicUrl: String
}
