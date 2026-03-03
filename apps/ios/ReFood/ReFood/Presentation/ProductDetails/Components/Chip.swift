import SwiftUI

struct Chip: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text)
            .foregroundStyle(tint)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(tint.opacity(0.20))
            .overlay(Capsule().stroke(tint.opacity(0.30)))
            .clipShape(Capsule())
    }
}
