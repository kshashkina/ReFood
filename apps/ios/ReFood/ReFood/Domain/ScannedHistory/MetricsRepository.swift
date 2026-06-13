import Foundation

protocol MetricsRepository {
    func getScannedCount() -> Int
    func getSortedCount() -> Int
    func incrementScannedCount()
    func incrementSortedCount()
    func getStreakCount() -> Int
    func updateStreak()
    func trackMapCheck()
    func trackProductAdded()
    func isAchievementUnlocked(id: String) -> Bool
    func getAchievementProgress(id: String) -> (current: Int, goal: Int)
    func getAchievementUnlockDate(id: String) -> Date?
}

