import SwiftUI
import SwiftData

@main
struct ReFoodApp: App {
    init() {
        AmplifyConfigurator.configure()
        SentryConfigurator.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: ScannedHistoryModel.self)
    }
}
