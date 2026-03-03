import SwiftUI

struct NutritionRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.white.opacity(0.60))
                .font(.system(size: 14))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
        }
    }
}
