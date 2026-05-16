import SwiftUI
import SwiftData

struct SearchBarView: View {
    @Binding var searchText: String
    var isSearchFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isSearchFocused.wrappedValue ? .appAccent : .white.opacity(0.5))
                .font(.system(size: 16, weight: .semibold))
            
            TextField(LocalizedStringKey("search_placeholder"), text: $searchText)
                .focused(isSearchFocused)
                .foregroundColor(.white)
                .tint(.appAccent)
            
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appAccent)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSearchFocused.wrappedValue ? .appAccent : Color.white.opacity(0.1), lineWidth: isSearchFocused.wrappedValue ? 1.5 : 1)
        )
    }
}

struct SearchSegmentControlView: View {
    @Binding var showFavoritesOnly: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showFavoritesOnly = false }
            } label: {
                Text(String(localized: "search_segment_all"))
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(showFavoritesOnly ? Color.clear : .appAccent)
                    .foregroundColor(showFavoritesOnly ? .white : .black)
                    .cornerRadius(12)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showFavoritesOnly = true }
            } label: {
                Text(String(localized: "search_segment_favorites"))
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(showFavoritesOnly ? .appAccent : Color.clear)
                    .foregroundColor(showFavoritesOnly ? .black : .white)
                    .cornerRadius(12)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
    }
}

struct SearchListHeaderView: View {
    let showFavoritesOnly: Bool
    
    var body: some View {
        HStack {
            let titleKey: LocalizedStringKey = showFavoritesOnly ? "search_header_favorites" : "search_header_all"
            
            Text(titleKey)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct SearchEmptyStateView: View {
    let showFavoritesOnly: Bool
    let isSearching: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            let titleKey: LocalizedStringKey = if isSearching {
                "search_empty_title_not_found"
            } else if showFavoritesOnly {
                "search_empty_title_no_favorites"
            } else {
                "search_empty_title_history"
            }
            
            let descKey: LocalizedStringKey = if isSearching {
                "search_empty_desc_not_found"
            } else if showFavoritesOnly {
                "search_empty_desc_no_favorites"
            } else {
                "search_empty_desc_history"
            }

            Text(titleKey)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(descKey)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundColor(.white.opacity(0.15))
        )
    }
}

struct SearchHistoryListView: View {
    let uiModels: [SearchItemUIModel]
    let showFavoritesOnly: Bool
    let isSearching: Bool
    var isSearchFocused: FocusState<Bool>.Binding
    
    let onProductTap: (Product) -> Void
    let onToggleFavorite: (SearchItemUIModel) -> Void
    let onDelete: (SearchItemUIModel) -> Void

    var body: some View {
        List {
            if uiModels.isEmpty {
                SearchEmptyStateView(showFavoritesOnly: showFavoritesOnly, isSearching: isSearching)
                    .padding(.top, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(uiModels) { uiModel in
                    SearchProductRowView(
                        uiModel: uiModel,
                        onTap: {
                            if let decodedProduct = uiModel.product {
                                isSearchFocused.wrappedValue = false
                                onProductTap(decodedProduct)
                            }
                        },
                        onToggleFavorite: { onToggleFavorite(uiModel) },
                        onDelete: { onDelete(uiModel) }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.bottom, 85)
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                if isSearchFocused.wrappedValue { isSearchFocused.wrappedValue = false }
            }
        )
    }
}

struct SearchProductRowView: View {
    let uiModel: SearchItemUIModel
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    private let cardBg = Color.white.opacity(0.04)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 56, height: 56)

                    if let urlString = uiModel.imageUrl, let url = URL(string: urlString) {
                        CachedAsyncImage(url: url, contentMode: .fill) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.appAccent.opacity(0.5))
                                .font(.system(size: 24))
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.appAccent.opacity(0.7))
                            .font(.system(size: 24))
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    Text(uiModel.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(uiModel.brand).font(.system(size: 13, weight: .medium)).foregroundColor(.gray).lineLimit(1)
                        Circle().fill(Color.gray.opacity(0.6)).frame(width: 3, height: 3)
                        Text(uiModel.timeAgo)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray.opacity(0.7))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button(action: onToggleFavorite) {
                    Image(systemName: uiModel.originalModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(uiModel.originalModel.isFavorite ? .appAccent : .gray.opacity(0.4))
                        .scaleEffect(uiModel.originalModel.isFavorite ? 1.1 : 1.0)
                }
                .buttonStyle(.borderless)
            }
            .padding(14)
            .background(cardBg)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(uiModel.originalModel.isFavorite ? Color.appAccent.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash").foregroundStyle(.white)
            }
            .tint(.red)
        }
    }
}
