import SwiftUI

struct ProfileAuthCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.appAccent.opacity(0.2)).frame(width: 56, height: 56)
                    Image(systemName: "applelogo").font(.system(size: 24)).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "profile_auth_title"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(String(localized: "profile_auth_subtitle"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(LinearGradient(colors: [Color.appAccent.opacity(0.15), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appAccent.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct ProfileStatCard: View {
    let icon: String
    let value: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(iconColor.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(iconColor).font(.system(size: 18, weight: .semibold))
            }
            VStack(spacing: 4) {
                Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(title).font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct ProfileRowButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconTint: Color
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, iconTint: Color = .white, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconTint = iconTint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white.opacity(0.05)).frame(width: 40, height: 40)
                    Image(systemName: icon).foregroundColor(iconTint).font(.system(size: 16, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 16, weight: .medium)).foregroundColor(.white)
                    if let subtitle = subtitle {
                        Text(subtitle).font(.system(size: 12, weight: .regular)).foregroundColor(.white.opacity(0.4))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.2))
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct ProfileLinkedCard: View {
    let greeting: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.appAccent.opacity(0.2)).frame(width: 56, height: 56)
                Image(systemName: "checkmark.seal.fill").font(.system(size: 24)).foregroundColor(.appAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 16)
            Image(systemName: "applelogo").font(.system(size: 20)).foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(LinearGradient(colors: [Color.appAccent.opacity(0.15), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appAccent.opacity(0.3), lineWidth: 1))
    }
}
