import Foundation
@testable import ReFood

final class MockMetricsRepository: MetricsRepositoryProtocol {
    var scannedCount = 0
    var sortedCount = 0
    var streakCount = 1
    var addedProductsCount = 0
    
    var achievementProgress: [String: (current: Int, goal: Int)] = [:]
    var unlockedAchievements: Set<String> = []
    
    var incrementScannedCountCalled = false
    var incrementSortedCountCalled = false
    var updateStreakCalled = false
    var trackMapCheckCalled = false
    var trackProductAddedCalled = false
    
    func getScannedCount() -> Int {
        scannedCount
    }
    
    func getSortedCount() -> Int {
        sortedCount
    }
    
    func incrementScannedCount() {
        incrementScannedCountCalled = true
        scannedCount += 1
    }
    
    func incrementSortedCount() {
        incrementSortedCountCalled = true
        sortedCount += 1
    }
    
    func getStreakCount() -> Int {
        streakCount
    }
    
    func updateStreak() {
        updateStreakCalled = true
    }
    
    func trackMapCheck() {
        trackMapCheckCalled = true
    }
    
    func trackProductAdded() {
        trackProductAddedCalled = true
        addedProductsCount += 1
    }
    
    func isAchievementUnlocked(id: String) -> Bool {
        unlockedAchievements.contains(id)
    }
    
    func getAchievementProgress(id: String) -> (current: Int, goal: Int) {
        achievementProgress[id] ?? (0, 1)
    }
}
