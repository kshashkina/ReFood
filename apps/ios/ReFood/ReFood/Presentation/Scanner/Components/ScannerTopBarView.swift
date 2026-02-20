import SwiftUI

struct ScannerTopBarView: View {

    let title: String
    let onClose: () -> Void

    let isTorchOn: Bool
    let onTapTorch: () -> Void

    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        HStack {
            Button(action: onClose) {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.80))

            Spacer()

            Button(action: onTapTorch) {
                Circle()
                    .fill(isTorchOn ? accent : Color.white.opacity(0.10))
                    .overlay(
                        Circle().stroke(isTorchOn ? accent : Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isTorchOn ? .black : .white)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(height: 40)
    }
}
