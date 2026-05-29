import SwiftUI

struct AchievementsTopBar: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.60))
                .frame(height: 132)
                .overlay(
                    HStack(spacing: 16) {
                        CircleBackButton { onBack() }
                        Text(String(localized: "profile_menu_achievements"))
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

struct AchievementProgressHeader: View {
    let progressText: String
    let fraction: Double
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text("🏆").font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "achievement_header_progress_title"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                    .textCase(.uppercase)
                
                Text(progressText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1))
                        Capsule()
                            .fill(Color.appAccent)
                            .frame(width: geo.size.width * CGFloat(fraction))
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct AchievementRow: View {
    let model: AchievementUIModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(model.isUnlocked ? Color.appAccent.opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                
                Image(systemName: model.isUnlocked ? model.icon : "lock.fill")
                    .foregroundColor(model.isUnlocked ? .appAccent : .white.opacity(0.3))
                    .font(.system(size: 22, weight: .medium))
            }
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(model.isUnlocked ? Color.appAccent.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(model.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(model.isUnlocked ? .white : .white.opacity(0.5))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if model.isUnlocked {
                        Image(systemName: "star.fill")
                            .foregroundColor(.appAccent)
                            .font(.system(size: 14))
                    }
                }
                
                Text(model.description)
                    .font(.system(size: 13))
                    .foregroundColor(model.isUnlocked ? .white.opacity(0.7) : .white.opacity(0.3))
                    .lineLimit(2)
                    .padding(.bottom, model.isUnlocked ? 2 : 4)
                
                if model.isUnlocked {
                    if let dateText = model.unlockDateText {
                        Text(dateText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.appAccent)
                    }
                } else {
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.08))
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: geo.size.width * CGFloat(model.progressFraction))
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(model.currentValue) / \(model.goalValue)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text(model.percentageText)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
        }
        .padding(16)
        .background(model.isUnlocked ? Color.white.opacity(0.03) : Color.white.opacity(0.01))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(model.isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.04), lineWidth: 1))
    }
}
