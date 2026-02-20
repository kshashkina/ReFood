import SwiftUI

struct MainTabBar: View {
    let onTapScanner: () -> Void
    @Binding var selected: MainTab

    private let active = Color(red: 144/255, green: 240/255, blue: 71/255)
    private let inactive = Color(red: 125/255, green: 133/255, blue: 119/255)

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home, title: "Home", system: "house")
            tabButton(.search, title: "Search", system: "magnifyingglass")

            scannerButton

            tabButton(.map, title: "Map", system: "map")
            tabButton(.profile, title: "Profile", system: "person")
        }
        .padding(12)
        .frame(height: 85)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.40))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 25, x: 0, y: 25)
        )
        .padding(.horizontal, 16)
    }

    private func tabButton(_ tab: MainTab, title: String, system: String) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: system)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selected == tab ? active : inactive)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var scannerButton: some View {
        Button {
            onTapScanner()
        } label: {
            ZStack {
                Circle()
                    .fill(active.opacity(0.5))
                    .frame(width: 84, height: 84)
                    .blur(radius: 20)

                RoundedRectangle(cornerRadius: 16)
                    .fill(active)
                    .frame(width: 56, height: 56)
                    .shadow(color: active.opacity(0.5), radius: 15)

                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 74, height: 59)
        .padding(.vertical, 8)
    }
}
