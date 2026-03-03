import SwiftUI

struct BulletRow: View {
    let text: String
    let accent: Color
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
                .shadow(color: accent.opacity(0.60), radius: 6)
            Text(text)
                .foregroundStyle(Color.white.opacity(0.90))
                .font(.system(size: 14))
            Spacer()
        }
    }
}
