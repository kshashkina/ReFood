import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var isEnabled: Bool = true
    
    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEnabled ? green : green.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: green.opacity(0.4), radius: 20, x: 0, y: 0)
        }
        .disabled(!isEnabled)
    }
}
