import SwiftUI

struct SettingsHeaderView: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.60))
                .frame(height: 132)
                .overlay(
                    HStack(spacing: 16) {
                        CircleBackButton { onBack() }
                        
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 68)
                    .padding(.bottom, 12)
                )
                .overlay(Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1), alignment: .bottom)
            Spacer()
        }
        .ignoresSafeArea()
    }
}


struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let iconTint: Color
    let bgTint: Color
    let borderTint: Color
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        iconTint: Color = .white,
        bgTint: Color = Color.white.opacity(0.03),
        borderTint: Color = Color.white.opacity(0.06),
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.iconTint = iconTint
        self.bgTint = bgTint
        self.borderTint = borderTint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(iconTint)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(12)
            .background(bgTint)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderTint, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
