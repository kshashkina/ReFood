import SwiftUI

struct PackagingRow: View {
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .medium))

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .foregroundStyle(Color.white.opacity(0.60))
                        .font(.system(size: 12))
                }
            }
            Spacer()
            Circle()
                .fill(accent)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 12)
        .frame(height: 64)
        .background(Color.white.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10)))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
