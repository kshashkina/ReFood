import SwiftUI

struct FormInputFieldModifier: ViewModifier {
    let accent: Color
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
            .tint(accent)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func inputStyle(accent: Color) -> some View {
        self.modifier(FormInputFieldModifier(accent: accent))
    }
}
