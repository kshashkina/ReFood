import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import AWSAPIPlugin

final class AmplifyAuthRepository: AuthRepositoryProtocol {
    func getIdentityId() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        
        guard let identityProvider = session as? AuthCognitoIdentityProvider else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Identity Provider not available"])
        }
        
        return try identityProvider.getIdentityId().get()
    }
}

final class AmplifyUserRepository: UserRepositoryProtocol {
    func registerUser(identityId: String, deviceId: String) async throws {
        let registrationData = ["identityId": identityId, "deviceId": deviceId]
        let body = try JSONEncoder().encode(registrationData)
        
        let request = RESTRequest(apiName: "ReFoodAPI", path: "/users/register", body: body)
        
        _ = try await Amplify.API.post(request: request)
    }
}

final class UserDefaultsLocalStorage: LocalStorageProtocol {
    private let key = "is_registered_with_backend"
    
    var isRegisteredWithBackend: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
