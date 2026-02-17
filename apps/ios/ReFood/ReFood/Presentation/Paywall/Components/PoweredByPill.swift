import SwiftUI

struct PoweredByPill: View {
    let green: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(green)

            Text("Powered by AI")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(green)
        }
        .padding(.leading, 12)
        .padding(.trailing, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(green.opacity(0.15))
                .overlay(Capsule().stroke(green.opacity(0.30), lineWidth: 0.6))
        )
    }
}
