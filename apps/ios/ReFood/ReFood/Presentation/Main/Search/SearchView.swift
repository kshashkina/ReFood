import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \ScannedHistoryModel.scanDate, order: .reverse) private var history: [ScannedHistoryModel]
    
    @StateObject private var vm: SearchViewModel
    @FocusState private var isSearchFocused: Bool

    var onProductTap: (Product) -> Void

    init(
        historyRepository: HistoryRepository,
        onProductTap: @escaping (Product) -> Void = { _ in }
    ) {
        self._vm = StateObject(wrappedValue: SearchViewModel(historyRepository: historyRepository))
        self.onProductTap = onProductTap
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
                .onTapGesture { isSearchFocused = false }

            VStack(spacing: 0) {
                MainHeaderView(title: String(localized: "tab_search"))
                    .padding(.bottom, 16)

                SearchBarView(searchText: $vm.searchText, isSearchFocused: $isSearchFocused)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                SearchSegmentControlView(showFavoritesOnly: $vm.showFavoritesOnly)
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
                    onProductTap: onProductTap,
                    onToggleFavorite: { uiModel in
                        vm.toggleFavorite(for: uiModel)
                    },
                    onDelete: { uiModel in
                        vm.delete(uiModel: uiModel)
                    }
                )
            }
        }
        .onAppear {
            vm.updateUIModels(from: history)
        }
        .onChange(of: history) { newHistory in
            vm.updateUIModels(from: newHistory)
        }
        .onChange(of: vm.searchText) { _ in
            vm.updateUIModels(from: history)
        }
        .onChange(of: vm.showFavoritesOnly) { _ in
            vm.updateUIModels(from: history)
        }
    }
}
