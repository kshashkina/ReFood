import SwiftUI

struct CloseCircleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.55))
                .frame(width: 39, height: 39)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 0.6))
        }
        .buttonStyle(.plain)
    }
}
