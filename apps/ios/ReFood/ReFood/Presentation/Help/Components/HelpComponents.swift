import SwiftUI

struct HelpTopBar: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.60))
                .frame(height: 132)
                .overlay(
                    HStack(spacing: 16) {
                        CircleBackButton { onBack() }
                        Text(String(localized: "profile_menu_help"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 68)
                    .padding(.bottom, 12)
                )
                .overlay(Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1), alignment: .bottom)
        }
        .ignoresSafeArea()
    }
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .top) {
                    Text(item.question)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.top, 2)
                }
                .padding(16)
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isExpanded ? Color.white.opacity(0.12) : Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}

struct ContactEmailButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "help_not_found_answer"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            Button(action: action) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.appAccent.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.appAccent)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "help_email_title"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(verbatim: "kayara.tech.team@gmail.com")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appAccent)
                            .tint(.appAccent)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.2))
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(16)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
