import Foundation
import SwiftData
import Combine
import SwiftUI

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
    private let productRepository: ProductRepository
    
    private static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.unitsStyle = .full
        return formatter
    }()
    
    init(historyRepository: HistoryRepository, productRepository: ProductRepository) {
        self.historyRepository = historyRepository
        self.productRepository = productRepository
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
            
            var decodedProduct = try? JSONDecoder().decode(Product.self, from: item.productData)
            decodedProduct?.barcode = item.id
            
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
        let currentStatus = uiModel.originalModel.isFavorite
        Task {
            try? await historyRepository.updateFavoriteStatus(id: uiModel.originalModel.id, isFavorite: currentStatus)
            try? await productRepository.toggleFavorite(barcode: uiModel.originalModel.id, isFavorite: currentStatus)
        }
        
        if showFavoritesOnly && !currentStatus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.uiModels.removeAll { $0.id == uiModel.id }
                }
            }
        }
    }
    
    func delete(uiModel: SearchItemUIModel, context: ModelContext) {
        if uiModel.originalModel.isFavorite {
            Task {try? await productRepository.toggleFavorite(barcode: uiModel.originalModel.id, isFavorite: false)}
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.uiModels.removeAll { $0.id == uiModel.id }
        }
        context.delete(uiModel.originalModel)
        try? context.save()
        Task {
            try? await historyRepository.deleteFromHistory(id: uiModel.originalModel.id)
        }
    }
}
