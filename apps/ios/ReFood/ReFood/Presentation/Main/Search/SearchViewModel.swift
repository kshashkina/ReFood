import Foundation
import SwiftData
import Combine

struct SearchItemUIModel: Identifiable {
    var id: String { originalModel.id }
    let originalModel: ScannedHistoryModel
    let name: String
    let brand: String
    let imageUrl: String?
    let timeAgo: String
    var product: Product? {
        try? JSONDecoder().decode(Product.self, from: originalModel.productData)
    }
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    
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
    
    func getUIModels(from history: [ScannedHistoryModel]) -> [SearchItemUIModel] {
        return history.compactMap { item in
            if showFavoritesOnly && !item.isFavorite { return nil }
            let name = item.productName
            let brand = item.brand
            
            if !searchText.isEmpty {
                let matchesSearch = name.localizedCaseInsensitiveContains(searchText) ||
                                    brand.localizedCaseInsensitiveContains(searchText)
                if !matchesSearch { return nil }
            }
            
            return SearchItemUIModel(
                originalModel: item,
                name: name,
                brand: brand,
                imageUrl: item.imageUrl,
                timeAgo: timeAgo(from: item.scanDate)
            )
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 60 {
            return String(localized: "search_time_just_now")
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
