import SwiftUI
import SwiftData
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin

@main
struct ReFoodApp: App {
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    let authRepo = AmplifyAuthRepository()
                    let userRepo = AmplifyUserRepository()
                    let localStorage = UserDefaultsLocalStorage()
                    let registrationUseCase = RegisterAnonymousUserUseCase(
                        authRepository: authRepo,
                        userRepository: userRepo,
                        localStorage: localStorage
                    )
                    await registrationUseCase.execute()
                }
        }
        .modelContainer(for: ScannedHistoryModel.self)
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
        } catch {
            print("Registration failed: \(error)")
        }
    }
}
