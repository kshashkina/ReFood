import SwiftUI

struct MainHeaderView: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.top, 64)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                Color.black.opacity(0.75)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.55), Color.clear],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 65)
                    .offset(x: 100, y: -60)
            }
            .ignoresSafeArea(edges: .top)
        )
    }
}
