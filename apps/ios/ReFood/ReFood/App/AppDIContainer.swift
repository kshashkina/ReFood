import Foundation
import Combine

@MainActor
final class AppDIContainer: ObservableObject {
    
    let analytics: AnalyticsServiceProtocol
    let deviceProvider: KeychainDeviceIDManager
    let localStorage: LocalStorageProtocol
    let languageProvider: SystemLanguageProvider
    let emailService: URLEmailService
    let dbCleaner: SwiftDataCleaner
    let cameraPermissionService: CameraPermissionService
    let locationPermissionService: LocationPermissionService
    let locationService: LocationService
    let networkMonitor: NetworkMonitor
    let authRepo: AmplifyAuthRepository
    let userRepo: UserRepositoryImpl
    let metricsRepo: MetricRepositoryImpl
    let historyRepo: HistoryRepositoryImpl
    let productRepo: ProductRepositoryImpl
    let aiRepo: AIComparisonRepositoryImpl
    let locationRepo: LocationRepositoryImpl
    let uploadService: ImageUploadService
    let dashboardRepo: DashboardRepositoryImpl
    let syncUseCase: SyncUserDataUseCase
    let linkUseCase: LinkAppleAccountUseCase
    let deleteUseCase: DeleteAccountUseCase
    let registerUseCase: RegisterAnonymousUserUseCase
    
    init() {
        self.analytics = AmplitudeAnalyticsService.shared
        self.deviceProvider = KeychainDeviceIDManager()
        self.localStorage = UserDefaultsLocalStorage()
        self.languageProvider = SystemLanguageProvider()
        self.emailService = URLEmailService()
        self.dbCleaner = SwiftDataCleaner()
        self.cameraPermissionService = CameraPermissionService()
        self.locationPermissionService = LocationPermissionService()
        self.locationService = LocationService()
        self.networkMonitor = NetworkMonitor.shared
        self.authRepo = AmplifyAuthRepository()
        self.userRepo = UserRepositoryImpl()
        self.metricsRepo = MetricRepositoryImpl()
        let hRepo = HistoryRepositoryImpl()
        self.historyRepo = hRepo
        self.dashboardRepo = DashboardRepositoryImpl()
        let pRepo = ProductRepositoryImpl()
        self.productRepo = pRepo
        self.aiRepo = AIComparisonRepositoryImpl()
        self.locationRepo = LocationRepositoryImpl()
        self.uploadService = ImageUploadService(repository: pRepo)
        
        let sUseCase = SyncUserDataUseCase(
            historyRepository: hRepo,
            productRepository: pRepo
        )
        self.syncUseCase = sUseCase
        
        self.linkUseCase = LinkAppleAccountUseCase(
            authRepository: self.authRepo,
            userRepository: self.userRepo,
            localStorage: self.localStorage,
            deviceIDProvider: self.deviceProvider,
            syncUseCase: sUseCase
        )
        
        self.deleteUseCase = DeleteAccountUseCase(
            authRepository: self.authRepo,
            userRepository: self.userRepo,
            localStorage: self.localStorage,
            deviceIDProvider: self.deviceProvider,
            databaseCleaner: self.dbCleaner,
            analytics: self.analytics
        )
        
        self.registerUseCase = RegisterAnonymousUserUseCase(
            authRepository: self.authRepo,
            userRepository: self.userRepo,
            localStorage: self.localStorage,
            deviceIDProvider: self.deviceProvider,
            analytics: self.analytics
        )
    }
}
