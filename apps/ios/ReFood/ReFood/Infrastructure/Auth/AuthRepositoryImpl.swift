import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import AWSAPIPlugin
import UIKit

final class AmplifyAuthRepository: AuthRepositoryProtocol {
    func getIdentityId() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        guard let identityProvider = session as? AuthCognitoIdentityProvider else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Identity Provider not available"])
        }
        return try identityProvider.getIdentityId().get()
    }
    
    @MainActor
    private func getWindow() -> UIWindow {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return UIWindow()
        }
        return window
    }
    
    func signInWithApple() async throws -> String {
        let window = await getWindow()
        do {
            _ = try await Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: window)
        } catch {
        }
        return try await fetchCurrentIdToken()
    }
    
    func fetchCurrentIdToken() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        guard let cognitoSession = session as? AWSAuthCognitoSession else {
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Session Type"])
        }
        return try cognitoSession.userPoolTokensResult.get().idToken
    }
    
    func signOut() async throws {
        let secClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for secClass in secClasses {
            SecItemDelete([kSecClass as String: secClass] as CFDictionary)
        }
    }
}

final class UserDefaultsLocalStorage: LocalStorageProtocol {
    var isRegisteredWithBackend: Bool {
        get { UserDefaults.standard.bool(forKey: "is_registered_with_backend") }
        set { UserDefaults.standard.set(newValue, forKey: "is_registered_with_backend") }
    }
    
    var isAppleLinked: Bool {
        get { UserDefaults.standard.bool(forKey: "is_apple_linked") }
        set { UserDefaults.standard.set(newValue, forKey: "is_apple_linked") }
    }
    
    func clearAllData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
}
