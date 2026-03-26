import SwiftUI

struct AIInsightCard: View {
    let text: String
    
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: accent.opacity(0.15), location: 0),
                            .init(color: Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.15), location: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 45)
                        .offset(x: 120, y: -50),
                    alignment: .topTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accent.opacity(0.25))
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(accent.opacity(0.4), lineWidth: 1)
                            )
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(accent)
                    }
                    Text("AI Analysis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Text(text)
                    .font(.system(size: 14, weight: .regular))
                    .lineSpacing(5)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
    }
}

