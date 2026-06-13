import Foundation

final class MetricRepositoryImpl: MetricsRepository {
    private let scannedKey = "scannedItemsCount"
    private let sortedKey = "sortedItemsCount"
    private let streakKey = "streakDaysCount"
    private let lastOpenedKey = "lastOpenedDate"
    private let addedProductsKey = "addedProductsCount"
    private let ninjaSortingKey = "achievement_ninja_sorting"
    private let earlyBirdKey = "achievement_early_bird"
    private let weekendScanKey = "weekend_has_scanned"
    private let weekendMapKey = "weekend_has_mapped"
    private let ecoWeekendUnlockedKey = "achievement_eco_weekend"

    private func saveUnlockDate(for id: String) {
        let key = "unlock_date_\(id)"
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(Date(), forKey: key)
        }
    }
    
    func getAchievementUnlockDate(id: String) -> Date? {
        let key = "unlock_date_\(id)"
        if isAchievementUnlocked(id: id) && UserDefaults.standard.object(forKey: key) == nil {
            saveUnlockDate(for: id)
        }
        return UserDefaults.standard.object(forKey: key) as? Date
    }

    func getScannedCount() -> Int {
        UserDefaults.standard.integer(forKey: scannedKey)
    }
    
    func getSortedCount() -> Int {
        UserDefaults.standard.integer(forKey: sortedKey)
    }
    
    func incrementScannedCount() {
        let current = getScannedCount()
        let newCount = current + 1
        UserDefaults.standard.set(newCount, forKey: scannedKey)
        if newCount >= 1 { saveUnlockDate(for: "first_step") }
        if newCount >= 10 { saveUnlockDate(for: "active_user") }
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 9 {
            UserDefaults.standard.set(true, forKey: earlyBirdKey)
            saveUnlockDate(for: "early_bird")
        }
        if Calendar.current.isDateInWeekend(Date()) {
            UserDefaults.standard.set(true, forKey: weekendScanKey)
            checkEcoWeekendAchievement()
        }
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
        let newStreak = getStreakCount()
        if newStreak >= 7 { saveUnlockDate(for: "week_streak") }
        if newStreak >= 30 { saveUnlockDate(for: "eco_addict") }
    }
        
    func trackMapCheck() {
        let hour = Calendar.current.component(.hour, from: Date())
        let isWeekend = Calendar.current.isDateInWeekend(Date())
        
        if hour >= 20 || isWeekend {
            UserDefaults.standard.set(true, forKey: ninjaSortingKey)
            saveUnlockDate(for: "ninja_sorting")
        }
        if isWeekend {
            UserDefaults.standard.set(true, forKey: weekendMapKey)
            checkEcoWeekendAchievement()
        }
    }
    
    func trackProductAdded() {
        let current = UserDefaults.standard.integer(forKey: addedProductsKey)
        let newCount = current + 1
        UserDefaults.standard.set(newCount, forKey: addedProductsKey)
        if newCount >= 5 { saveUnlockDate(for: "master_informer") }
    }
    
    private func checkEcoWeekendAchievement() {
        let hasScanned = UserDefaults.standard.bool(forKey: weekendScanKey)
        let hasMapped = UserDefaults.standard.bool(forKey: weekendMapKey)
        if hasScanned && hasMapped {
            UserDefaults.standard.set(true, forKey: ecoWeekendUnlockedKey)
            saveUnlockDate(for: "eco_weekend")
        }
    }
        
    func isAchievementUnlocked(id: String) -> Bool {
        let progress = getAchievementProgress(id: id)
        return progress.current >= progress.goal
    }
    
    func getAchievementProgress(id: String) -> (current: Int, goal: Int) {
        switch id {
        case "first_step":
            return (getScannedCount(), 1)
        case "active_user":
            return (getScannedCount(), 10)
        case "week_streak":
            return (getStreakCount(), 7)
        case "ninja_sorting":
            return (UserDefaults.standard.bool(forKey: ninjaSortingKey) ? 1 : 0, 1)
        case "early_bird":
            return (UserDefaults.standard.bool(forKey: earlyBirdKey) ? 1 : 0, 1)
        case "eco_weekend":
            return (UserDefaults.standard.bool(forKey: ecoWeekendUnlockedKey) ? 1 : 0, 1)
        case "master_informer":
            return (UserDefaults.standard.integer(forKey: addedProductsKey), 5)
        case "eco_addict":
            return (getStreakCount(), 30)
        default:
            return (0, 1)
        }
    }
}
