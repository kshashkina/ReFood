import SwiftUI
import AVFoundation

struct ScannerView: View {

    let session: AVCaptureSession
    let onClose: () -> Void
    let onTapTorch: (_ isOn: Bool) -> Void
    let onTapManualInput: () -> Void
    let onTapScan: () -> Void

    @State private var isTorchOn: Bool = false

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

                Spacer()

                ScannerOverlayFrameView()
                    .frame(width: 288, height: 288)

                Spacer()

                ScannerBottomPanelView(
                    title: "Point your camera at the barcode",
                    subtitle: "Position the barcode inside the frame",
                    onTapManualInput: onTapManualInput,
                    onTapScan: onTapScan
                )
            }
        }
    }
}

#Preview {
    ScannerView(
        session: AVCaptureSession(),
        onClose: {},
        onTapTorch: { _ in },
        onTapManualInput: {},
        onTapScan: {}
    )
}
