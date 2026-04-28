import SwiftUI

struct ManualInputTextField: View {
    @Binding var text: String
    var focus: FocusState<Bool>.Binding
    var onFilter: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("manualInput_label_barcode")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                
                Spacer()
                
                if focus.wrappedValue {
                    Button("common_done") {
                        withAnimation(.spring()) {
                            focus.wrappedValue = false
                        }
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.appAccent)
                    .clipShape(Capsule())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .frame(height: 32)

            TextField("1234567890123", text: $text)
                .keyboardType(.numberPad)
                .focused(focus)
                .padding(18)
                .background(Color.white.opacity(0.06))
                .cornerRadius(18)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(focus.wrappedValue ? Color.appAccent.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    onFilter(newValue)
                }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: focus.wrappedValue)
    }
}

struct ManualInputTitleGroup: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("manualInput_title")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text("manualInput_subtitle")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct ManualInputFeatureCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [Color.appAccent.opacity(0.12), Color.green.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                )
            
            HStack(spacing: 20) {
                FeatureIcon(systemName: "shippingbox")
                FeatureIcon(systemName: "leaf")
                FeatureIcon(systemName: "arrow.triangle.2.circlepath")
            }
        }
        .frame(height: 120)
    }
}

struct FeatureIcon: View {
    let systemName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .frame(width: 75, height: 75)
            
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.appAccent)
        }
    }
}

struct BarcodeTipView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.appAccent)
            Text("manualInput_tip_length")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
