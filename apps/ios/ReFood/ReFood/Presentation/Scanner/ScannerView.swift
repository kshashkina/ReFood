import SwiftUI
import AVFoundation

struct ScannerView: View {

    let session: AVCaptureSession
    let isLoading: Bool
    let onClose: () -> Void
    let onTapTorch: (_ isOn: Bool) -> Void
    let onTapManualInput: () -> Void
    let onTapScan: () -> Void

    @State private var isTorchOn: Bool = false
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {

            CameraPreviewView(session: session)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.4),
                    Color(red: 10/255, green: 10/255, blue: 10/255).opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScannerTopBarView(
                    title: "Scanning",
                    onClose: onClose,
                    isTorchOn: isTorchOn,
                    onTapTorch: {
                        isTorchOn.toggle()
                        onTapTorch(isTorchOn)
                    }
                )
                .padding(.top)
                .padding(.horizontal, 24)
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1)

                Spacer()

                ScannerOverlayFrameView()
                    .frame(width: 288, height: 288)
                    .opacity(isLoading ? 0.4 : 1)

                Spacer()

                ScannerBottomPanelView(
                    title: "Point your camera at the barcode",
                    subtitle: "Position the barcode inside the frame",
                    onTapManualInput: onTapManualInput,
                    onTapScan: onTapScan
                )
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1)
            }
            if isLoading {
                Rectangle()
                    .fill(.black.opacity(0.25))
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(accent)
                    Text("Searching product…")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(accent)
                    Text("Fetching data from database")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 28)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.black.opacity(0.75))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(accent.opacity(0.35), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.6), radius: 20, y: 10)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLoading)
    }
}
