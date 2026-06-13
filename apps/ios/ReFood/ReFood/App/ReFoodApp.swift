import SwiftUI
import SwiftData

@main
struct ReFoodApp: App {
    @StateObject private var container = AppDIContainer()
    init() {
        AmplifyConfigurator.configure()
        SentryConfigurator.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
        .modelContainer(for: ScannedHistoryModel.self)
    }
}
