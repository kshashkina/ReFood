import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void = {}
    
    @State private var logoScale: CGFloat = 0.86
    @State private var logoRotation: Double = 0

    @State private var textScale: CGFloat = 0.86
    @State private var textOpacity: Double = 0.0

    private let glowCenterX: CGFloat = 7 + 384/2
    private let glowCenterY: CGFloat = 122 + 384/2

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Circle()
                .fill(Color(red: 144/255, green: 240/255, blue: 71/255).opacity(0.20))
                .frame(width: 384, height: 384)
                .blur(radius: 70)
                .opacity(0.8)
                .position(x: glowCenterX, y: glowCenterY)

            VStack(spacing: 20) {
                LogoCard()
                    .frame(width: 128, height: 128)
                    .rotationEffect(.degrees(logoRotation), anchor: .center)
                    .scaleEffect(logoScale)

                Text("ReFood")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(0.95)
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
            }
            .position(x: glowCenterX, y: glowCenterY)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                logoScale = 1.0
            }

            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = 6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    logoRotation = 0
                }
            }

            withAnimation(.easeInOut(duration: 2.0)) {
                textScale = 1.0
                textOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            onFinish()
                        }
        }
    }
}

private struct LogoCard: View {
    private let green = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: green.opacity(0.30), location: 0.25),
                            .init(color: Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.30), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(green.opacity(0.30), lineWidth: 0.56)
                )
                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 12)

            Image("Logo")
                .resizable()
                .scaledToFit()
        }
        .frame(width: 128, height: 128)
    }
}

#Preview {
    SplashView()
}
