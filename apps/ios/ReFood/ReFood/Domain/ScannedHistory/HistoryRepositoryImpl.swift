import Foundation
import SwiftData

@MainActor
final class HistoryRepositoryImpl: HistoryRepository {
    private let container: ModelContainer
    private let context: ModelContext
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init() {
        do {
            container = try ModelContainer(for: ScannedHistoryModel.self)
            context = ModelContext(container)
        } catch {
            fatalError("SwiftData initialization failed: \(error)")
        }
    }
    
    func saveProduct(_ product: Product, isFavorite: Bool = false) async throws {
        let data = try encoder.encode(product)
        let id = product.barcode
        let name = product.productName ?? String(localized: "common_unknown")
        let brand = product.brands ?? String(localized: "search_unknown_brand")
        let imageUrl = product.imageUrl

        let fetchDescriptor = FetchDescriptor<ScannedHistoryModel>(predicate: #Predicate { $0.id == id })
        
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.scanDate = Date()
            existing.productData = data
            existing.productName = name
            existing.brand = brand
            existing.imageUrl = imageUrl
        } else {
            let newModel = ScannedHistoryModel(
                id: id,
                productData: data,
                scanDate: Date(),
                isFavorite: isFavorite,
                productName: name,
                brand: brand,
                imageUrl: imageUrl
            )
            context.insert(newModel)
        }
        try context.save()
    }
    
    func getAllHistory() async throws -> [ScannedHistoryItem] {
        var descriptor = FetchDescriptor<ScannedHistoryModel>(sortBy: [SortDescriptor(\.scanDate, order: .reverse)])
        let models = try context.fetch(descriptor)
        return models.compactMap { model -> ScannedHistoryItem? in
            guard var product = try? decoder.decode(Product.self, from: model.productData) else { return nil }
            product.barcode = model.id
            return ScannedHistoryItem(
                id: model.id,
                product: product,
                scanDate: model.scanDate,
                isFavorite: model.isFavorite
            )
        }
    }
    
    func updateFavoriteStatus(id: String, isFavorite: Bool) async throws {
        let fetchDescriptor = FetchDescriptor<ScannedHistoryModel>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.isFavorite = isFavorite
            try context.save()
        }
    }

    func deleteFromHistory(id: String) async throws {
        let fetchDescriptor = FetchDescriptor<ScannedHistoryModel>(predicate: #Predicate { $0.id == id })
        if let model = try context.fetch(fetchDescriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
