import Foundation

protocol MetricsRepositoryProtocol {
    func getScannedCount() -> Int
    func getSortedCount() -> Int
}

final class UserDefaultsMetricsRepository: MetricsRepositoryProtocol {
    func getScannedCount() -> Int {
        UserDefaults.standard.integer(forKey: "scannedItemsCount")
    }
    
    func getSortedCount() -> Int {
        UserDefaults.standard.integer(forKey: "sortedItemsCount")
    }
}
