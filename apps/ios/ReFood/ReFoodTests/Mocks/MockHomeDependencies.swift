import Foundation
@testable import ReFood

final class MockMetricsRepository: MetricsRepositoryProtocol {
    var scannedCount = 0
    var sortedCount = 0
    
    func getScannedCount() -> Int {
        scannedCount
    }
    
    func getSortedCount() -> Int {
        sortedCount
    }
    
    func incrementScannedCount() {
        scannedCount += 1
    }
    
    func incrementSortedCount() {
        sortedCount += 1
    }
}
