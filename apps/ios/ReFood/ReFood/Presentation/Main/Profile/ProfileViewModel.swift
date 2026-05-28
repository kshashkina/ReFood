import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var scannedCount: String = "0"
    @Published var sortedCount: String = "0"
    @Published var streakCount: String = "0"
    
    @Published var isLinked: Bool = false
    @Published var isLoading: Bool = false
    @Published var greetingText: String = ""
    
    private let metricsRepository: MetricsRepositoryProtocol
    private let linkAccountUseCase: LinkAppleAccountUseCase
    private var localStorage: LocalStorageProtocol
    
    init(
        metricsRepository: MetricsRepositoryProtocol,
        linkAccountUseCase: LinkAppleAccountUseCase,
        localStorage: LocalStorageProtocol
    ) {
        self.metricsRepository = metricsRepository
        self.linkAccountUseCase = linkAccountUseCase
        self.localStorage = localStorage
        
        self.isLinked = localStorage.isAppleLinked
        
        loadMetrics()
        updateGreeting()
    }
    
    func loadMetrics() {
        self.scannedCount = "\(metricsRepository.getScannedCount())"
        self.sortedCount = "\(metricsRepository.getSortedCount())"
        self.streakCount = "\(metricsRepository.getStreakCount())"
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: greetingText = String(localized: "profile_greeting_morning")
        case 12..<17: greetingText = String(localized: "profile_greeting_afternoon")
        case 17..<22: greetingText = String(localized: "profile_greeting_evening")
        default: greetingText = String(localized: "profile_greeting_night")
        }
    }
    
    func linkAppleAccount() {
        isLoading = true
        Task {
            do {
                try await linkAccountUseCase.execute()
                self.isLinked = true
                self.updateGreeting()
            } catch {
            }
            isLoading = false
        }
    }
}
