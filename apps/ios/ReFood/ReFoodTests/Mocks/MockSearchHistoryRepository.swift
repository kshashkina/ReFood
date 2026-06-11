import Foundation
@testable import ReFood

final class MockSearchHistoryRepository: HistoryRepository {
    var savedProduct: Product?
    var savedFavoriteStatus: Bool?
    var historyItems: [ScannedHistoryItem] = []
    var deletedId: String?
    var updatedFavoriteId: String?
    var updatedFavoriteStatus: Bool?
    
    func saveProduct(_ product: Product, isFavorite: Bool) async throws {
        savedProduct = product
        savedFavoriteStatus = isFavorite
    }
    
    func getAllHistory() async throws -> [ScannedHistoryItem] {
        historyItems
    }
    
    func deleteFromHistory(id: String) async throws {
        deletedId = id
    }
    
    func updateFavoriteStatus(id: String, isFavorite: Bool) async throws {
        updatedFavoriteId = id
        updatedFavoriteStatus = isFavorite
    }
}
