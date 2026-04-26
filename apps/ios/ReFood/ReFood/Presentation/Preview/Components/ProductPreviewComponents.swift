import SwiftUI

struct PreviewTopBar: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.black.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)
            .overlay(
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(Color.appAccent)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                            )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
            )
            Spacer()
        }
        .ignoresSafeArea()
    }
}

struct PreviewImageSection: View {
    let imageUrl: URL?
    
    var body: some View {
        GeometryReader { geo in
            let side = geo.size.width - 32
            ZStack {
                CachedAsyncImage(url: imageUrl, contentMode: .fill) {
                    ZStack {
                        Color.white.opacity(0.05)
                        Image(systemName: "photo")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                }
                .frame(width: side, height: side)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.appAccent, lineWidth: 2)
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
        .frame(height: 360)
        .padding(.top, 12)
    }
}

struct PreviewHeaderSection: View {
    let name: String
    let brand: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)

            Text(brand)
                .font(.system(size: 17))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
    }
}

struct PreviewConfirmCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.appAccent.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Color.appAccent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("preview_confirm_title")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))

                Text("preview_confirm_subtitle")
                    .foregroundStyle(Color.white.opacity(0.6))
                    .font(.system(size: 14))
            }
            Spacer()
        }
        .padding(16)
        .background(Color.appAccent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PreviewActionButtons: View {
    let continueTitle: String
    let onContinue: () -> Void
    let onScanAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onContinue) {
                HStack {
                    Text(continueTitle)
                        .foregroundStyle(.black)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.appAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onScanAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("preview_btn_scan_again")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }
}
