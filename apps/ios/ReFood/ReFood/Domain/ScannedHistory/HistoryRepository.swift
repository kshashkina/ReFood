import Foundation

protocol HistoryRepository {
    func saveProduct(_ product: Product, isFavorite: Bool) async throws
    func getAllHistory() async throws -> [ScannedHistoryItem]
    func deleteFromHistory(id: String) async throws
    func updateFavoriteStatus(id: String, isFavorite: Bool) async throws
}
