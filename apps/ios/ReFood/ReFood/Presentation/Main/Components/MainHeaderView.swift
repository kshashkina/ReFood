import SwiftUI

struct MainHeaderView: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 64)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
                .padding(.horizontal, -24)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.60))
    }
}
