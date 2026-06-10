import Foundation

final class UserRepositoryImpl: UserRepositoryProtocol {
    
    func registerUser(identityId: String, deviceId: String) async throws {
        _ = try await UserAPI.registerUser(identityId: identityId, deviceId: deviceId)
    }
    
    func linkAccount(idToken: String, deviceId: String) async throws {
        _ = try await UserAPI.linkAccount(idToken: idToken, deviceId: deviceId)
    }
    
    func deleteUser(idToken: String) async throws {
        _ = try await UserAPI.deleteUser(idToken: idToken)
    }
}
