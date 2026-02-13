import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    private let iconFixedTopOffset: CGFloat = 100

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Circle()
                .fill(green.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 64)
                .opacity(0.50)
                .offset(y: iconFixedTopOffset - 60)

            VStack(spacing: 0) {

                ZStack {
                    Circle()
                        .fill(green.opacity(0.35))
                        .frame(width: 243, height: 243)
                        .blur(radius: 40)

                    IconCard(imageName: page.imageName)
                }
                .frame(height: 240) 
                .padding(.top, iconFixedTopOffset)

                Text(page.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(page.subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.top, 14)

                Spacer()

                Color.clear
                    .frame(height: 140)
            }
        }
    }
}

private struct IconCard: View {
    let imageName: String
    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: green.opacity(0.30), location: 0.25),
                            .init(color: Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.30), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(green.opacity(0.22), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .padding(1)

            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .frame(width: 162, height: 162)
    }
}
