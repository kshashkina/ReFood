import Foundation

protocol MetricsRepositoryProtocol {
    func getScannedCount() -> Int
    func getSortedCount() -> Int
    func incrementScannedCount()
    func incrementSortedCount()
    func getStreakCount() -> Int
    func updateStreak()
}

final class UserDefaultsMetricsRepository: MetricsRepositoryProtocol {
    private let scannedKey = "scannedItemsCount"
    private let sortedKey = "sortedItemsCount"
    private let streakKey = "streakDaysCount"
    private let lastOpenedKey = "lastOpenedDate"
    
    func getScannedCount() -> Int {
        UserDefaults.standard.integer(forKey: scannedKey)
    }
    
    func getSortedCount() -> Int {
        UserDefaults.standard.integer(forKey: sortedKey)
    }
    
    func incrementScannedCount() {
        let current = getScannedCount()
        UserDefaults.standard.set(current + 1, forKey: scannedKey)
    }
    
    func incrementSortedCount() {
        let current = getSortedCount()
        UserDefaults.standard.set(current + 1, forKey: sortedKey)
    }
        
    func getStreakCount() -> Int {
        let count = UserDefaults.standard.integer(forKey: streakKey)
        return count == 0 ? 1 : count
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        let defaults = UserDefaults.standard
        let lastOpened = defaults.object(forKey: lastOpenedKey) as? Date
        
        if let lastOpened = lastOpened {
            if calendar.isDateInToday(lastOpened) {
                return
            } else if calendar.isDateInYesterday(lastOpened) {
                let currentStreak = getStreakCount()
                defaults.set(currentStreak + 1, forKey: streakKey)
            } else {
                defaults.set(1, forKey: streakKey)
            }
        } else {
            defaults.set(1, forKey: streakKey)
        }
        defaults.set(now, forKey: lastOpenedKey)
    }
}
