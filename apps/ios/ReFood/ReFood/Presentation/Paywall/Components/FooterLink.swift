import SwiftUI

struct FooterLink: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.50))
                .underline()
        }
        .buttonStyle(.plain)
    }
}
