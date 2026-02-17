import SwiftUI

struct PlanCard: View {
    let title: String
    let subtitle: String
    let price: String
    let period: String
    let isSelected: Bool
    let green: Color
    let selectedGradient: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.50))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(period)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.white.opacity(0.50))
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.67)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isSelected && selectedGradient {
            LinearGradient(
                colors: [green.opacity(0.20), green.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.white.opacity(0.04)
        }
    }

    private var borderColor: Color {
        isSelected ? green : Color.white.opacity(0.08)
    }
}
