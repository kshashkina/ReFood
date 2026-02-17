import SwiftUI

struct PaywallView: View {
    let onClose: () -> Void

    enum Plan { case weekly, yearly }
    @State private var selectedPlan: Plan = .weekly

    var body: some View {
        ZStack {
            PaywallTheme.bg.ignoresSafeArea()

            glowBackground

            VStack(spacing: 0) {
                header

                FeaturesCard(green: PaywallTheme.green)
                    .padding(.top, 20)

                plans
                    .padding(.top, 14)

                PrimaryButton(title: "Continue") {}
                .padding(.top, 18)

                Button {} label: {
                    Text("Restore Purchases")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.50))
                }
                .padding(.top, 14)

                footer
                    .padding(.top, 10)

                Spacer(minLength: 18)
            }
            .padding(.horizontal, 24)
        }
    }

    private var glowBackground: some View {
        ZStack {
            Circle()
                .fill(PaywallTheme.green.opacity(0.20))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .position(x: UIScreen.main.bounds.width / 2, y: 205)

            Circle()
                .fill(PaywallTheme.green.opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 80)
                .position(x: UIScreen.main.bounds.width / 2, y: 418)
        }
    }

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                PoweredByPill(green: PaywallTheme.green)

                Text("Unlock the Power of AI")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 9)

                Text("Your personal AI assistant for healthy eating")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)

            CloseCircleButton {onClose()}
            .padding(.trailing, 5)
        }
    }

    private var plans: some View {
        VStack(spacing: 6) {
            PlanCard(
                title: "Weekly Subscription",
                subtitle: "Try it for 7 days",
                price: "$3.99",
                period: "/week",
                isSelected: selectedPlan == .weekly,
                green: PaywallTheme.green,
                selectedGradient: true
            ) { selectedPlan = .weekly }

            PlanCard(
                title: "Yearly Subscription",
                subtitle: "Only $2.49 per month",
                price: "$29.99",
                period: "/year",
                isSelected: selectedPlan == .yearly,
                green: PaywallTheme.green,
                selectedGradient: true
            ) { selectedPlan = .yearly }
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Text("Auto-renewable subscription. Cancel anytime.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.40))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                FooterLink("Terms of Service") {}
                Text("•").foregroundStyle(.white.opacity(0.30))
                FooterLink("Privacy Policy") {}
                Text("•").foregroundStyle(.white.opacity(0.30))
                FooterLink("Subscription Terms") {}
            }
        }
    }
}
