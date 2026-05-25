import Foundation
import SwiftData
import Combine

struct SearchItemUIModel: Identifiable {
    let id: String
    let originalModel: ScannedHistoryModel
    let name: String
    let brand: String
    let imageUrl: String?
    let timeAgo: String
    let product: Product?
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    @Published var uiModels: [SearchItemUIModel] = []
    
    private let historyRepository: HistoryRepository
    
    private static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.unitsStyle = .full
        return formatter
    }()
    
    init(historyRepository: HistoryRepository) {
        self.historyRepository = historyRepository
    }
    
    func updateUIModels(from history: [ScannedHistoryModel]) {
        self.uiModels = history.compactMap { item in
            if showFavoritesOnly && !item.isFavorite { return nil }
            let name = item.productName
            let brand = item.brand
            
            if !searchText.isEmpty {
                let matchesSearch = name.localizedCaseInsensitiveContains(searchText) ||
                                    brand.localizedCaseInsensitiveContains(searchText)
                if !matchesSearch { return nil }
            }
            
            let decodedProduct = try? JSONDecoder().decode(Product.self, from: item.productData)
            
            return SearchItemUIModel(
                id: item.id,
                originalModel: item,
                name: name,
                brand: brand,
                imageUrl: item.imageUrl,
                timeAgo: timeAgo(from: item.scanDate),
                product: decodedProduct
            )
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 60 {
            return String(localized: "search_time_just_now", defaultValue: "Щойно")
        }
        return Self.timeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    func toggleFavorite(for uiModel: SearchItemUIModel) {
        let newStatus = !uiModel.originalModel.isFavorite
        Task {
            try? await historyRepository.updateFavoriteStatus(id: uiModel.originalModel.id, isFavorite: newStatus)
        }
    }
    
    func delete(uiModel: SearchItemUIModel) {
        Task {
            try? await historyRepository.deleteFromHistory(id: uiModel.originalModel.id)
        }
    }
}
