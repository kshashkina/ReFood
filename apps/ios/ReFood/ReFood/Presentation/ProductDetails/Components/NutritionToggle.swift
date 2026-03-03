import SwiftUI

struct NutritionToggle: View {
    @Binding var selection: ProductDetailsScreen.NutritionTab
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ProductDetailsScreen.NutritionTab.allCases, id: \.self) { mode in
                Button {
                    selection = mode
                } label: {
                    Text(mode.rawValue)
                        .foregroundStyle(selection == mode ? Color.black : Color.white.opacity(0.60))
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selection == mode ? accent : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(selection == mode ? 0 : 0.10))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
