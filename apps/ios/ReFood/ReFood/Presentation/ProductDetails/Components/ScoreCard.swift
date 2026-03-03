import SwiftUI

struct ScoreCard: View {
    let title: String
    let grade: String
    let subtitle: String
    let tint: Color

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 17) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundStyle(Color.white.opacity(0.60))
                    .font(.system(size: 12))
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(tint.opacity(0.16))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.28)))
                            .frame(width: 46, height: 48)
                        Text(grade)
                            .foregroundStyle(tint)
                            .font(.system(size: 24, weight: .bold))
                    }
                    Text(subtitle)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .medium))
                    Spacer(minLength: 0)
                }
            }
        }
    }
}
