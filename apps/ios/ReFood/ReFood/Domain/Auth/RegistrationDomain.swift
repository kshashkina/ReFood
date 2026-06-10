import Foundation
import UIKit

protocol AuthRepositoryProtocol {
    func getIdentityId() async throws -> String
    func signInWithApple() async throws -> String
    func fetchCurrentIdToken() async throws -> String
    func signOut() async throws
    func repairExpiredSessionIfNeeded() async
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
    func hasExistingDeviceID() -> Bool
}

protocol DatabaseCleanerProtocol {
    func clearAllLocalData() async
}

final class RegisterAnonymousUserUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    private let analytics: AnalyticsServiceProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        localStorage: LocalStorageProtocol,
        deviceIDProvider: DeviceIDProviderProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
        self.analytics = analytics
    }
    
    func execute() async {
        let isReinstall = deviceIDProvider.hasExistingDeviceID()
        let deviceId = deviceIDProvider.getDeviceID()
        analytics.setUserId(deviceId)
        
        guard !localStorage.isRegisteredWithBackend else { return }
        
        do {
            let identityId = try await authRepository.getIdentityId()
            try await userRepository.registerUser(identityId: identityId, deviceId: deviceId)
            localStorage.isRegisteredWithBackend = true
            if isReinstall {
                analytics.track(AppLifecycleEvent.reinstall)
            } else {
                analytics.track(AppLifecycleEvent.firstLaunch)
            }
        } catch {
        }
    }
}

final class LinkAppleAccountUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    private let syncUseCase: SyncUserDataUseCase
    
    init(authRepository: AuthRepositoryProtocol, userRepository: UserRepositoryProtocol, localStorage: LocalStorageProtocol, deviceIDProvider: DeviceIDProviderProtocol, syncUseCase: SyncUserDataUseCase) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
        self.syncUseCase = syncUseCase
    }
    
    func execute() async throws {
        let idToken = try await authRepository.signInWithApple()
        let deviceId = deviceIDProvider.getDeviceID()
        try await userRepository.linkAccount(idToken: idToken, deviceId: deviceId)
        localStorage.isAppleLinked = true
        
        Task(priority: .background) {
            await syncUseCase.execute()
        }
    }
}

final class DeleteAccountUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var localStorage: LocalStorageProtocol
    private let deviceIDProvider: DeviceIDProviderProtocol
    private let databaseCleaner: DatabaseCleanerProtocol
    private let analytics: AnalyticsServiceProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        localStorage: LocalStorageProtocol,
        deviceIDProvider: DeviceIDProviderProtocol,
        databaseCleaner: DatabaseCleanerProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.localStorage = localStorage
        self.deviceIDProvider = deviceIDProvider
        self.databaseCleaner = databaseCleaner
        self.analytics = analytics
    }
    
    func execute() async throws {
        let idToken = try await authRepository.fetchCurrentIdToken()
        try await userRepository.deleteUser(idToken: idToken)
        try await authRepository.signOut()
        
        deviceIDProvider.resetDeviceID()
        localStorage.clearAllData()
        await databaseCleaner.clearAllLocalData()
        analytics.track(AppLifecycleEvent.accountDeleted)
        analytics.resetUser()
    }
}

final class SyncUserDataUseCase {
    private let historyRepository: HistoryRepository
    private let productRepository: ProductRepository
    
    init(historyRepository: HistoryRepository, productRepository: ProductRepository) {
        self.historyRepository = historyRepository
        self.productRepository = productRepository
    }
    
    func execute() async {
        async let achievementsTask = try? SyncAPI.fetchAchievements()
        async let scansTask = try? SyncAPI.fetchScans()
        async let favoritesTask = try? SyncAPI.fetchFavorites()
        async let dashboardTask = try? SyncAPI.fetchDashboard()
        
        let achievements = await achievementsTask
        let scans = await scansTask ?? []
        let favorites = await favoritesTask ?? []
        let dashboard = await dashboardTask
        
        if let profile = dashboard?.profile {
            if let scanned = profile.scannedCount {
                let currentScanned = UserDefaults.standard.integer(forKey: "scannedItemsCount")
                UserDefaults.standard.set(max(currentScanned, scanned), forKey: "scannedItemsCount")
            }
            if let sorted = profile.sortedCount {
                let currentSorted = UserDefaults.standard.integer(forKey: "sortedItemsCount")
                UserDefaults.standard.set(max(currentSorted, sorted), forKey: "sortedItemsCount")
            }
        }
        
        if let achievementsData = achievements {
            for achievement in achievementsData.achievements {
                let countKey = getDefaultsKey(for: achievement.id)
                if !countKey.isEmpty {
                    let currentLocal = UserDefaults.standard.integer(forKey: countKey)
                    UserDefaults.standard.set(max(currentLocal, achievement.current), forKey: countKey)
                }
                
                if achievement.isUnlocked {
                    let unlockKey = "unlock_date_\(achievement.id)"
                    if UserDefaults.standard.object(forKey: unlockKey) == nil {
                        UserDefaults.standard.set(Date(), forKey: unlockKey)
                    }
                    if achievement.id == "eco_weekend" {
                        UserDefaults.standard.set(true, forKey: "achievement_eco_weekend")
                    }
                    if achievement.id == "ninja_sorting" {
                        UserDefaults.standard.set(true, forKey: "achievement_ninja_sorting")
                    }
                    if achievement.id == "early_bird" {
                        UserDefaults.standard.set(true, forKey: "achievement_early_bird")
                    }
                }
            }
        }
        
        let favoriteBarcodes = Set(favorites)
        let scanBarcodes = Set(scans)
        let allBarcodes = scanBarcodes.union(favoriteBarcodes)
        
        for barcode in allBarcodes {
            do {
                let product = try await productRepository.getProduct(byBarcode: barcode)
                let isFavorite = favoriteBarcodes.contains(barcode)
                try await historyRepository.saveProduct(product, isFavorite: isFavorite)
            } catch {
            }
        }
    }
    
    private func getDefaultsKey(for id: String) -> String {
        switch id {
        case "master_informer": return "addedProductsCount"
        case "week_streak", "eco_addict": return "streakDaysCount"
        default: return ""
        }
    }
}
