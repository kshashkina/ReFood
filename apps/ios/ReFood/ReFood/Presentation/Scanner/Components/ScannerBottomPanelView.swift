import SwiftUI

struct ScannerBottomPanelView: View {
    
    let title: String
    let subtitle: String
    let onTapManualInput: () -> Void
    let onTapScan: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.60),
                    Color.black.opacity(0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 332)
            .overlay(contentOverlay, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var contentOverlay: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
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
                        
                        Text("Enter barcode manually")
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
                
                PrimaryButton(title: "Scan") {
                    onTapScan()
                }
                .frame(height: 52)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: 332)
    }
}
