import SwiftUI

struct ManualInputScreen: View {
    @StateObject private var vm = ManualInputViewModel()
    let onBack: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var previewProduct: Product? = nil
    @State private var showAddProduct = false
    
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Manual Input")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)

                        Text("Enter the product barcode manually")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    glowCard
                    inputSection

                    Spacer()

                    Button {
                        isFocused = false
                        Task { await vm.findProduct() }
                    } label: {
                        Text("Find Product")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isValid ? accent : Color.white.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .disabled(!isValid)
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $vm.isLoading) {
            ProductLoadingSheet(
                isPresented: $vm.isLoading,
                progress: vm.loadingProgress,
                currentStep: vm.currentStep,
                isFailed: vm.isFailed,
                onFinish: {
                    vm.isLoading = false
                    if let p = vm.product { previewProduct = p }
                },
                onTryAgain: { vm.isLoading = false },
                onAddProduct: {
                    vm.isLoading = false
                    showAddProduct = true
                }
            )
            .presentationDetents([.height(560)])
        }
        .fullScreenCover(item: $previewProduct) { product in
            ProductPreviewScreen(
                product: product,
                onBack: { previewProduct = nil },
                onContinue: {
                    previewProduct = nil
                },
                onScanAgain: { previewProduct = nil }
            )
        }
        .fullScreenCover(isPresented: $showAddProduct) {
            AddProductScreen(barcode: vm.barcode)
        }
    }
    
    private var isValid: Bool {
        vm.barcode.count >= 7 && vm.barcode.count <= 14 && !vm.isLoading
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                Text("Barcode")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                if isFocused {
                    Button("Done") { isFocused = false }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(accent).clipShape(Capsule())
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                }
            }.frame(height: 32)

            TextField("1234567890123", text: $vm.barcode)
                .keyboardType(.numberPad)
                .padding(18)
                .background(Color.white.opacity(0.06))
                .cornerRadius(18)
                .foregroundColor(.white)
                .focused($isFocused)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(isFocused ? accent.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1))
                .onChange(of: vm.barcode) { newValue in
                    vm.barcode = String(newValue.filter { $0.isNumber }.prefix(14))
                }

            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill").foregroundColor(accent)
                Text("Barcode is usually 7–14 digits.").font(.system(size: 13)).foregroundColor(.white.opacity(0.6))
            }.padding(16).background(Color.white.opacity(0.05)).cornerRadius(16)
        }
        .animation(.spring(), value: isFocused)
    }
    
    private var glowCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [accent.opacity(0.12), Color.green.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(accent.opacity(0.2), lineWidth: 1))
            HStack(spacing: 20) {
                iconCard(systemName: "shippingbox")
                iconCard(systemName: "leaf")
                iconCard(systemName: "arrow.triangle.2.circlepath")
            }
        }.frame(height: 125)
    }

    private func iconCard(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1)).frame(width: 80, height: 80)
            Image(systemName: systemName).resizable().scaledToFit().frame(width: 36, height: 36).foregroundColor(accent)
        }
    }
}
