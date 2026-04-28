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

                FeaturesCard()
                    .padding(.top, 20)

                plans
                    .padding(.top, 14)

                PrimaryButton(title: String(localized: "paywall_btn_continue")) {}
                .padding(.top, 18)

                Button {} label: {
                    Text("paywall_btn_restore")
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
                .fill(Color.appAccent.opacity(0.20))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .position(x: UIScreen.main.bounds.width / 2, y: 205)

            Circle()
                .fill(Color.appAccent.opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 80)
                .position(x: UIScreen.main.bounds.width / 2, y: 418)
        }
    }

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                PoweredByPill()

                Text("paywall_title")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 9)

                Text("paywall_subtitle")
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
                title: "paywall_plan_weekly_title",
                subtitle: "paywall_plan_weekly_subtitle",
                price: "$3.99",
                period: "paywall_plan_weekly_period",
                isSelected: selectedPlan == .weekly,
                selectedGradient: true
            ) { selectedPlan = .weekly }

            PlanCard(
                title: "paywall_plan_yearly_title",
                subtitle: "paywall_plan_yearly_subtitle",
                price: "$29.99",
                period: "paywall_plan_yearly_period",
                isSelected: selectedPlan == .yearly,
                selectedGradient: true
            ) { selectedPlan = .yearly }
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Text("paywall_footer_disclaimer")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.40))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                FooterLink("paywall_footer_terms") {}
                Text("•").foregroundStyle(.white.opacity(0.30))
                FooterLink("paywall_footer_privacy") {}
                Text("•").foregroundStyle(.white.opacity(0.30))
                FooterLink("paywall_footer_sub_terms") {}
            }
        }
    }
}
