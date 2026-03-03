import SwiftUI

struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(height: 1)
            .padding(.vertical, 6)
    }
}
