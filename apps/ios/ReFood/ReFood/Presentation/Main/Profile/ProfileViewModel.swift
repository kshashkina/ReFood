import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var scannedCount: String = "0"
    @Published var sortedCount: String = "0"
    @Published var streakCount: String = "0"
    
    private let metricsRepository: MetricsRepositoryProtocol
    
    init(metricsRepository: MetricsRepositoryProtocol) {
        self.metricsRepository = metricsRepository
        loadMetrics()
    }
    
    func loadMetrics() {
        self.scannedCount = "\(metricsRepository.getScannedCount())"
        self.sortedCount = "\(metricsRepository.getSortedCount())"
        self.streakCount = "\(metricsRepository.getStreakCount())"
    }
}
