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

struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appAccent.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.50))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FeaturesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(
                icon: "sparkles",
                title: "paywall_feature_ai_title",
                subtitle: "paywall_feature_ai_subtitle"
            )
            FeatureRow(
                icon: "arrow.left.and.right.circle",
                title: "paywall_feature_compare_title",
                subtitle: "paywall_feature_compare_subtitle"
            )
            FeatureRow(
                icon: "nosign",
                title: "paywall_feature_adfree_title",
                subtitle: "paywall_feature_adfree_subtitle"
            )
            FeatureRow(
                icon: "bolt",
                title: "paywall_feature_unlimited_title",
                subtitle: "paywall_feature_unlimited_subtitle"
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.6)
        )
    }
}

struct FooterLink: View {
    let titleKey: LocalizedStringKey
    let action: () -> Void

    init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.titleKey = titleKey
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(titleKey)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.50))
                .underline()
        }
        .buttonStyle(.plain)
    }
}

struct PlanCard: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let price: String
    let period: LocalizedStringKey
    let isSelected: Bool
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
                colors: [Color.appAccent.opacity(0.20), Color.appAccent.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.white.opacity(0.04)
        }
    }

    private var borderColor: Color {
        isSelected ? .appAccent : Color.white.opacity(0.08)
    }
}

struct PoweredByPill: View {

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            Text("paywall_powered_by_ai")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appAccent)
        }
        .padding(.leading, 12)
        .padding(.trailing, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.appAccent.opacity(0.15))
                .overlay(Capsule().stroke(Color.appAccent.opacity(0.30), lineWidth: 0.6))
        )
    }
}
enum PaywallTheme {
    static let bg = Color(red: 0x0A/255, green: 0x0F/255, blue: 0x0A/255)
}
