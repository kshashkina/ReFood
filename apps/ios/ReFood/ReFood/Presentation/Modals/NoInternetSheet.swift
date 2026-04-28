import SwiftUI

struct NoInternetSheet: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.red.opacity(0.3), lineWidth: 1))
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.red)
            }
            .padding(.top, 24)
            
            VStack(spacing: 12) {
                Text(LocalizedStringKey("network_error_title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("network_error_desc"))
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Text(LocalizedStringKey("common_got_it"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(red: 26/255, green: 26/255, blue: 26/255).ignoresSafeArea())
    }
}
