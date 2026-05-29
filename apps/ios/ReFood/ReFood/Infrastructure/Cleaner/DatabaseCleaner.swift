import SwiftData
import Foundation

final class SwiftDataCleaner: DatabaseCleanerProtocol {
    @MainActor
    func clearAllLocalData() async {
        do {
            let container = try ModelContainer(for: ScannedHistoryModel.self)
            let context = container.mainContext
            let descriptor = FetchDescriptor<ScannedHistoryModel>()
            let items = try context.fetch(descriptor)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch {
        }
    }
}
