import Foundation

struct AchievementDTO: Decodable {
    let id: String
    let current: Int
    let isUnlocked: Bool
}

struct AchievementsResponse: Decodable {
    let achievements: [AchievementDTO]
    let totalUnlocked: Int
    let total: Int
}

struct ScansResponse: Decodable {
    let scans: [ScanItemDTO]
}

struct ScanItemDTO: Decodable {
    let barcode: String
}

struct DashboardResponse: Decodable {
    let profile: UserProfileDTO
}

struct UserProfileDTO: Decodable {
    let scannedCount: Int?
    let sortedCount: Int?
}
