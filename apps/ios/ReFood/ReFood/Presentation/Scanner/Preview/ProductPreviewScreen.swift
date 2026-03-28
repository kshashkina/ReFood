import SwiftUI

struct ProductPreviewScreen: View {
    let product: Product
    var firstProductForComparison: Product? = nil
    let onBack: () -> Void
    let onContinue: () -> Void
    let onScanAgain: () -> Void

    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                imageSection
                content
                Spacer()
            }
            topBar
        }
    }

    private var imageSection: some View {
        GeometryReader { geo in
            let side = geo.size.width - 32
            ZStack {
                CachedAsyncImage(
                    url: URL(string: product.imageUrl ?? ""),
                    contentMode: .fill
                ) {
                    placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: side, height: side)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(accent, lineWidth: 2)
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
        .frame(height: 360)
        .padding(.top, 12)
    }

    private var placeholder: some View {
        ZStack {
            Color.white.opacity(0.05)
            Image(systemName: "photo")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.3))
        }
    }

    private var topBar: some View {
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
                            .fill(accent)
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

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(product.productName ?? "Unknown product")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)

                Text(product.brands ?? "")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            confirmCard
                .padding(.top, 24)
                .padding(.horizontal, 28)

            buttons
                .padding(.top, 20)
                .padding(.horizontal, 28)
        }
    }

    private var confirmCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Is this the correct product?")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))

                Text("Please make sure this is the item you were looking for")
                    .foregroundStyle(Color.white.opacity(0.6))
                    .font(.system(size: 14))
            }
            Spacer()
        }
        .padding(16)
        .background(accent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button(action: onContinue) {
                HStack {
                    Text(continueButtonTitle)
                        .foregroundStyle(.black)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onScanAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Scan again")
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

    private var continueButtonTitle: String {
        if let first = firstProductForComparison {
            let brand = first.brands?.components(separatedBy: ",").first ?? "previous"
            return "Compare with \(brand)"
        }
        return "Yes, continue"
    }
}
