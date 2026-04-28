import SwiftUI
import AVFoundation

struct ScannerBottomPanelView: View {
    let titleKey: String
    let subtitleKey: String
    let onTapManualInput: () -> Void
    let onTapScan: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.60),
                    Color.black.opacity(0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            contentOverlay
        }
        .frame(maxWidth: .infinity)
        .frame(height: 332)
    }
    
    private var contentOverlay: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 8) {
                Text(LocalizedStringKey(titleKey))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey(subtitleKey))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button(action: onTapManualInput) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text(LocalizedStringKey("scanner_btn_manual"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                Button(action: onTapScan) {
                    Text(LocalizedStringKey("scanner_btn_scan"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.appAccent)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: 332)
    }
}

struct ScannerOverlayFrameView: View {
    var body: some View {
        ZStack {
            corner(top: true, left: true)
                .frame(width: 48, height: 48)
                .position(x: 24, y: 24)

            corner(top: true, left: false)
                .frame(width: 48, height: 48)
                .position(x: 288 - 24, y: 24)

            corner(top: false, left: true)
                .frame(width: 48, height: 48)
                .position(x: 24, y: 390 - 24)

            corner(top: false, left: false)
                .frame(width: 48, height: 48)
                .position(x: 288 - 24, y: 390 - 24)
        }
    }

    private func corner(top: Bool, left: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .trim(from: 0, to: 0.25)
            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .foregroundStyle(Color.appAccent)
            .rotationEffect(.degrees(rotation(top: top, left: left)))
    }

    private func rotation(top: Bool, left: Bool) -> Double {
        switch (top, left) {
        case (true, true): return 180
        case (true, false): return 270
        case (false, true): return 90
        case (false, false): return 0
        }
    }
}

struct ScannerTopBarView: View {
    let titleKey: String
    let onClose: () -> Void
    let isTorchOn: Bool
    let onTapTorch: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .overlay(Circle().stroke(Color.white.opacity(0.20), lineWidth: 1))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.80))

            Spacer()

            Button(action: onTapTorch) {
                Circle()
                    .fill(isTorchOn ? Color.appAccent : Color.white.opacity(0.10))
                    .overlay(Circle().stroke(isTorchOn ? Color.appAccent : Color.white.opacity(0.20), lineWidth: 1))
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

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
