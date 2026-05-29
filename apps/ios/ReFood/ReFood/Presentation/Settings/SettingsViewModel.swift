import Foundation
import UIKit
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var appVersion: String = ""
    @Published var isLinked: Bool = false
    
    private let deleteAccountUseCase: DeleteAccountUseCase
    
    init(deleteAccountUseCase: DeleteAccountUseCase, localStorage: LocalStorageProtocol) {
        self.deleteAccountUseCase = deleteAccountUseCase
        self.isLinked = localStorage.isAppleLinked
        self.appVersion = fetchAppVersion()
    }
    
    private func fetchAppVersion() -> String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            let localizedPrefix = String(localized: "settings_app_version")
            return "\(localizedPrefix) \(version)"
        }
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func deleteAccount() {
            isLoading = true
            Task {
                do {
                    try await deleteAccountUseCase.execute()
                    self.isLinked = false
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                } catch {
                }
                isLoading = false
            }
        }
}
