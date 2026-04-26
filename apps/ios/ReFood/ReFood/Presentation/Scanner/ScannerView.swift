import SwiftUI
import AVFoundation

struct ScannerView: View {
    let session: AVCaptureSession
    let onClose: () -> Void
    let isTorchOn: Bool
    let onTapTorch: () -> Void
    let onTapManualInput: () -> Void
    let onTapScan: () -> Void


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
                    titleKey: "scanner_title",
                    onClose: onClose,
                    isTorchOn: isTorchOn,
                    onTapTorch: onTapTorch 
                )
                .padding(.top)
                .padding(.horizontal, 24)

                Spacer()

                ScannerOverlayFrameView()
                    .frame(width: 288, height: 288)

                Spacer()

                ScannerBottomPanelView(
                    titleKey: "scanner_hint_title",
                    subtitleKey: "scanner_hint_subtitle",
                    onTapManualInput: onTapManualInput,
                    onTapScan: onTapScan
                )
            }
        }
    }
}
