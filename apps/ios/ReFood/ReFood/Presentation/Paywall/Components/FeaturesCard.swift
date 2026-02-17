import SwiftUI

struct FeaturesCard: View {
    let green: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(
                icon: "sparkles",
                title: "AI Product Analysis",
                subtitle: "Artificial intelligence analyzes ingredients and provides personalized recommendations",
                green: green
            )
            FeatureRow(
                icon: "arrow.left.and.right.circle",
                title: "Smart Product Comparison",
                subtitle: "Compare two products and choose the healthier option",
                green: green
            )
            FeatureRow(
                icon: "nosign",
                title: "Ad-Free Experience",
                subtitle: "Experience the app without intrusive ads and stay fully focused on your health goals",
                green: green
            )
            FeatureRow(
                icon: "bolt",
                title: "Unlimited Access",
                subtitle: "Unlock unlimited scans and powerful AI insights whenever you need them",
                green: green
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
