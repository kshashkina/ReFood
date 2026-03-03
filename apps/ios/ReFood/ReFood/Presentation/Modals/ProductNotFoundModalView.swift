import SwiftUI

struct ProductNotFoundModalView: View {

    @Binding var isPresented: Bool

    let barcode: String
    let onTryAgain: () -> Void
    let onAddProduct: () -> Void
    let onClose: () -> Void

    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.50))
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            card
                .padding(.horizontal, 31)
        }
    }

    private var card: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 26/255, green: 26/255, blue: 26/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.10), lineWidth: 0.56)
                )
                .shadow(color: accent.opacity(0.60), radius: 34)

            VStack(spacing: 0) {

                ZStack {
                    Rectangle()
                        .fill(accent)
                        .frame(width: 40, height: 61)
                        .blur(radius: 24)

                    Image("ProductNotFound")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                }
                .padding(.top, 24)

                Text("Product Not Found")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text("We couldn’t find this barcode \n in our database")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                Button {
                    isPresented = false
                    onTryAgain()
                } label: {
                    Text("Scan Another Product")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(accent)
                        .cornerRadius(16)
                        .shadow(color: accent.opacity(0.40), radius: 15)
                }
                .padding(.top, 18)
                .padding(.horizontal, 24)

                Button {
                    onAddProduct()
                } label: {
                    Text("Add Product to Database")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(16)
                }
                .padding(.top, 12)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            Button {
                isPresented = false
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .frame(width: 32, height: 32)
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .frame(maxWidth: 340)
        .frame(height: 405)
    }
}
