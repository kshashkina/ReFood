import SwiftUI
import SwiftData

struct SearchBarView: View {
    @Binding var searchText: String
    var isSearchFocused: FocusState<Bool>.Binding
    var onClearTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isSearchFocused.wrappedValue ? .appAccent : .white.opacity(0.4))
                .font(.system(size: 16, weight: .semibold))
            
            TextField(LocalizedStringKey("search_placeholder"), text: $searchText)
                .focused(isSearchFocused)
                .foregroundColor(.white)
                .tint(.appAccent)
            
            if !searchText.isEmpty {
                Button {
                    onClearTap()
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appAccent.opacity(0.8))
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSearchFocused.wrappedValue ?
                    LinearGradient(colors: [.appAccent.opacity(0.6), .appAccent.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: isSearchFocused.wrappedValue ? Color.appAccent.opacity(0.15) : .clear, radius: 10, y: 4)
    }
}

struct SearchSegmentControlView: View {
    @Binding var showFavoritesOnly: Bool
    var onToggle: (Bool) -> Void
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            SegmentButton(
                title: String(localized: "search_segment_all"),
                isSelected: !showFavoritesOnly,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { showFavoritesOnly = false }
                onToggle(false)
            }

            SegmentButton(
                title: String(localized: "search_segment_favorites"),
                isSelected: showFavoritesOnly,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { showFavoritesOnly = true }
                onToggle(true)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    var animation: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(isSelected ? .black : .white.opacity(0.6))
                .contentShape(Rectangle())
        }
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appAccent)
                        .matchedGeometryEffect(id: "TabBackground", in: animation)
                        .shadow(color: Color.appAccent.opacity(0.3), radius: 8, y: 4)
                }
            }
        )
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

struct SearchSkeletonRow: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 140, height: 14)
                
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 80, height: 10)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.02))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct SearchEmptyStateView: View {
    let showFavoritesOnly: Bool
    let isSearching: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                SearchSkeletonRow().opacity(1)
                SearchSkeletonRow().opacity(0.8)
                SearchSkeletonRow().opacity(0.6)
                SearchSkeletonRow().opacity(0.4)
                SearchSkeletonRow().opacity(0.2)
            }
            .allowsHitTesting(false)
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
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(descKey)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(Color.black.opacity(0.2))
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
            .padding(.top, 60)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            } else {
                ForEach(uiModels) { uiModel in
                    SearchProductRowView(
                        uiModel: uiModel,
                        model: uiModel.originalModel,
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
        .padding(.bottom, 135)
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                if isSearchFocused.wrappedValue { isSearchFocused.wrappedValue = false }
            }
        )
    }
}

struct SearchProductRowView: View {
    let uiModel: SearchItemUIModel
    @Bindable var model: ScannedHistoryModel
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 56, height: 56)

                    if let urlString = uiModel.imageUrl, let url = URL(string: urlString) {
                        CachedAsyncImage(url: url, contentMode: .fill) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.appAccent.opacity(0.5))
                                .font(.system(size: 24))
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.appAccent.opacity(0.5))
                            .font(.system(size: 24))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(uiModel.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(uiModel.brand)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                        Circle().fill(Color.white.opacity(0.3)).frame(width: 3, height: 3)
                        Text(uiModel.timeAgo)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button(action: {
                    model.isFavorite.toggle()
                    onToggleFavorite()
                }) {
                    Image(systemName: model.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(model.isFavorite ? .appAccent : .white.opacity(0.2))
                        .shadow(color: model.isFavorite ? Color.appAccent.opacity(0.5) : .clear, radius: 4, y: 0)
                        .scaleEffect(model.isFavorite ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: model.isFavorite)
                }
                .buttonStyle(.borderless)
            }
            .padding(14)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.15), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(model.isFavorite ? 1.0 : 0.0)
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        model.isFavorite ?
                        LinearGradient(colors: [.appAccent.opacity(0.4), .clear], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.25), value: model.isFavorite)
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
