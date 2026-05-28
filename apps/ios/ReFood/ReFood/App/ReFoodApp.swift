import SwiftUI
import SwiftData

@main
struct ReFoodApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: ScannedHistoryModel.self)
    }
}
