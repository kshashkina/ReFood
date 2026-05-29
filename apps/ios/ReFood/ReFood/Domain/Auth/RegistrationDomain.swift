import Foundation
import UIKit

protocol AuthRepositoryProtocol {
    func getIdentityId() async throws -> String
    func signInWithApple() async throws -> String
    func fetchCurrentIdToken() async throws -> String
    func signOut() async throws
}

protocol UserRepositoryProtocol {
    func registerUser(identityId: String, deviceId: String) async throws
    func linkAccount(idToken: String, deviceId: String) async throws
    func deleteUser(idToken: String) async throws
}

protocol LocalStorageProtocol {
    var isRegisteredWithBackend: Bool { get set }
    var isAppleLinked: Bool { get set }
    func clearAllData()
}

protocol DeviceIDProviderProtocol {
    func getDeviceID() -> String
    func resetDeviceID()
}

protocol DatabaseCleanerProtocol {
    func clearAllLocalData() async
}

final class RegisterAnonymousUserUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    
    init(authRepository: AuthRepositoryProtocol, userRepository: UserRepositoryProtocol, localStorage: LocalStorageProtocol, deviceIDProvider: DeviceIDProviderProtocol) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
    }
    
    func execute() async {
        guard !localStorage.isRegisteredWithBackend else { return }
        
        do {
            let identityId = try await authRepository.getIdentityId()
            let deviceId = deviceIDProvider.getDeviceID()
            try await userRepository.registerUser(identityId: identityId, deviceId: deviceId)
            localStorage.isRegisteredWithBackend = true
        } catch {
        }
    }
}

final class LinkAppleAccountUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    
    init(authRepository: AuthRepositoryProtocol, userRepository: UserRepositoryProtocol, localStorage: LocalStorageProtocol, deviceIDProvider: DeviceIDProviderProtocol) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
    }
    
    func execute() async throws {
        let idToken = try await authRepository.signInWithApple()
        let deviceId = deviceIDProvider.getDeviceID()
        try await userRepository.linkAccount(idToken: idToken, deviceId: deviceId)
        localStorage.isAppleLinked = true
    }
}

final class DeleteAccountUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    private let databaseCleaner: DatabaseCleanerProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        localStorage: LocalStorageProtocol,
        deviceIDProvider: DeviceIDProviderProtocol,
        databaseCleaner: DatabaseCleanerProtocol
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
        self.databaseCleaner = databaseCleaner
    }
    
    func execute() async throws {
        let idToken = try await authRepository.fetchCurrentIdToken()
        try await userRepository.deleteUser(idToken: idToken)
        try await authRepository.signOut()
        deviceIDProvider.resetDeviceID()
        localStorage.clearAllData()
        await databaseCleaner.clearAllLocalData()
    }
}
