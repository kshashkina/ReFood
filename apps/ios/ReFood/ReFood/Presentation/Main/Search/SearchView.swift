import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScannedHistoryModel.scanDate, order: .reverse) private var history: [ScannedHistoryModel]
    
    @StateObject private var vm: SearchViewModel
    @FocusState private var isSearchFocused: Bool

    let analytics: AnalyticsServiceProtocol
    var onProductTap: (Product) -> Void

    init(
        historyRepository: HistoryRepository,
        analytics: AnalyticsServiceProtocol,
        onProductTap: @escaping (Product) -> Void = { _ in }
    ) {
        self._vm = StateObject(wrappedValue: SearchViewModel(historyRepository: historyRepository))
        self.analytics = analytics
        self.onProductTap = onProductTap
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
                .onTapGesture { isSearchFocused = false }

            VStack(spacing: 0) {
                MainHeaderView(title: String(localized: "tab_search"))
                    .padding(.bottom, 16)

                SearchBarView(
                    searchText: $vm.searchText,
                    isSearchFocused: $isSearchFocused,
                    onClearTap: {
                        analytics.track(SearchEvent.closeTap)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                SearchSegmentControlView(
                    showFavoritesOnly: $vm.showFavoritesOnly,
                    onToggle: { isFavoritesTab in
                        if isFavoritesTab {
                            analytics.track(SearchEvent.toggleFavoriteTap)
                        } else {
                            analytics.track(SearchEvent.toggleAllTap)
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)

                SearchListHeaderView(showFavoritesOnly: vm.showFavoritesOnly)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                SearchHistoryListView(
                    uiModels: vm.uiModels,
                    showFavoritesOnly: vm.showFavoritesOnly,
                    isSearching: !vm.searchText.isEmpty,
                    isSearchFocused: $isSearchFocused,
                    onProductTap: { product in
                        analytics.track(SearchEvent.productTap(barcode: product.barcode))
                        onProductTap(product)
                    },
                    onToggleFavorite: { uiModel in
                        let isNowFavorite = uiModel.originalModel.isFavorite
                        let mode = isNowFavorite ? "on" : "off"
                        let currentTab = vm.showFavoritesOnly ? "favourite" : "all"
                        
                        analytics.track(SearchEvent.likeTap(mode: mode, toggle: currentTab, barcode: uiModel.id))
                        vm.toggleFavorite(for: uiModel)
                    },
                    onDelete: { uiModel in
                        analytics.track(SearchEvent.deleteProductTap(barcode: uiModel.id))
                        vm.delete(uiModel: uiModel, context: modelContext)
                    }
                )
            }
        }
        .onAppear {
            analytics.track(SearchEvent.screenView(count: history.count))
            vm.updateUIModels(from: history)
        }
        .onChange(of: isSearchFocused) { isFocused in
            if isFocused {
                analytics.track(SearchEvent.searchTap)
            }
        }
        .onChange(of: history) { newHistory in
            withAnimation(.easeInOut(duration: 0.3)) {
                vm.updateUIModels(from: newHistory)
            }
        }
        .onChange(of: vm.searchText) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                vm.updateUIModels(from: history)
            }
        }
        .onChange(of: vm.showFavoritesOnly) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                vm.updateUIModels(from: history)
            }
        }
    }
}
