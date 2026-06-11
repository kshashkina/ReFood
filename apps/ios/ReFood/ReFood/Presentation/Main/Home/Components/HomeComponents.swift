import SwiftUI

struct MainStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { geo in
                Image(systemName: icon).font(.system(size: 55, weight: .bold)).foregroundColor(Color.white.opacity(0.03)).position(x: geo.size.width - 15, y: geo.size.height - 15)
            }
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(value).font(.system(size: 32, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.5))
                }
            }.padding(16)
        }.frame(height: 105).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(LinearGradient(colors: [Color.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
}

struct InsightCard: View {
    let model: InsightUIModel
    let onLinkTap: (() -> Void)?
    @Environment(\.openURL) private var openURL
    
    init(model: InsightUIModel, onLinkTap: (() -> Void)? = nil) {
        self.model = model
        self.onLinkTap = onLinkTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(model.accentColor.opacity(0.15)).frame(width: 44, height: 44)
                    Text(model.emoji).font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(model.credibilityText).font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.4)).textCase(.uppercase).lineLimit(1)
                        Text("•").font(.system(size: 11)).foregroundColor(.white.opacity(0.2))
                        Text(model.date).font(.system(size: 11, weight: .semibold)).foregroundColor(.white.opacity(0.3))
                    }
                    Text(model.mainTitle).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                }
            }.padding(.bottom, 12)
            
            Text(model.bodyText).font(.system(size: 14, weight: model.linkURL != nil ? .medium : .regular)).foregroundColor(.white.opacity(0.85)).lineSpacing(4).lineLimit(3)
            
            if let linkString = model.linkURL, let url = URL(string: linkString) {
                Button(action: {
                    onLinkTap?()
                    openURL(url)
                }) {
                    HStack(spacing: 4) {
                        Text(String(localized: "home_read_article")).font(.system(size: 12, weight: .bold))
                        Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(model.accentColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(model.accentColor.opacity(0.15))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 14)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [model.accentColor.opacity(0.12), Color.white.opacity(0.015)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(LinearGradient(colors: [Color.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
}

struct RecentScansSection: View {
    let uiModels: [HomeProductUIModel]
    let onProductTap: (Product) -> Void
    let onSeeAllTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text(String(localized: "home_recent_scans")).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Spacer()
                Button(action: onSeeAllTap) {
                    Text(String(localized: "home_see_all")).font(.system(size: 12, weight: .bold)).foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color.appAccent).clipShape(Capsule())
                }
            }
            
            if uiModels.isEmpty {
                Text(String(localized: "home_empty_history")).font(.system(size: 14)).foregroundColor(.white.opacity(0.4)).padding(.vertical, 12)
            } else {
                VStack(spacing: 12) {
                    ForEach(uiModels) { item in
                        HomeProductRow(
                            uiModel: item,
                            onTap: {
                                if let product = item.product { onProductTap(product) }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct HomeProductRow: View {
    let uiModel: HomeProductUIModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white.opacity(0.05)).frame(width: 56, height: 56)
                    if let urlString = uiModel.imageUrl, let url = URL(string: urlString) {
                        CachedAsyncImage(url: url, contentMode: .fill) {
                            Image(systemName: "leaf.fill").foregroundColor(.appAccent.opacity(0.5)).font(.system(size: 24))
                        }.frame(width: 56, height: 56).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        Image(systemName: "leaf.fill").foregroundColor(.appAccent.opacity(0.5)).font(.system(size: 24))
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    Text(uiModel.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    HStack(spacing: 6) {
                        Text(uiModel.brand).font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.5)).lineLimit(1)
                        Circle().fill(Color.white.opacity(0.3)).frame(width: 3, height: 3)
                        Text(uiModel.timeAgoText).font(.system(size: 12, weight: .regular)).foregroundColor(.white.opacity(0.4)).lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.2))
            }
            .padding(14).background(LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)).cornerRadius(20).overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}
