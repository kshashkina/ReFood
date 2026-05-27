import Foundation
import UIKit

protocol AuthRepositoryProtocol {
    func getIdentityId() async throws -> String
}

protocol UserRepositoryProtocol {
    func registerUser(identityId: String, deviceId: String) async throws
}

protocol LocalStorageProtocol {
    var isRegisteredWithBackend: Bool { get set }
}

final class RegisterAnonymousUserUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    
    init(authRepository: AuthRepositoryProtocol, userRepository: UserRepositoryProtocol, localStorage: LocalStorageProtocol) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
    }
    
    func execute() async {
        guard !localStorage.isRegisteredWithBackend else { return }
        
        do {
            let identityId = try await authRepository.getIdentityId()
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
            
            try await userRepository.registerUser(identityId: identityId, deviceId: deviceId)
            
            localStorage.isRegisteredWithBackend = true
        } catch {
            print("Registration failed: \(error)") 
        }
    }
}
