import SwiftUI

struct CircleBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .buttonStyle(.plain) 
    }
}
