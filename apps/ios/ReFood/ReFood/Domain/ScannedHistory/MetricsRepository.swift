import Foundation

protocol MetricsRepositoryProtocol {
    func getScannedCount() -> Int
    func getSortedCount() -> Int
    func incrementScannedCount()
    func incrementSortedCount()
}

final class UserDefaultsMetricsRepository: MetricsRepositoryProtocol {
    private let scannedKey = "scannedItemsCount"
    private let sortedKey = "sortedItemsCount"
    
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
}
