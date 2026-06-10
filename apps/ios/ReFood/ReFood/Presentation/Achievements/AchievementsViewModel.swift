import Foundation
import SwiftUI
import Combine

struct AchievementUIModel: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let currentValue: Int
    let goalValue: Int
    let isUnlocked: Bool
    let unlockDateText: String?
    
    var progressFraction: Double {
        guard goalValue > 0 else { return 0 }
        return min(1.0, Double(currentValue) / Double(goalValue))
    }
    
    var percentageText: String {
        "\(Int(progressFraction * 100))%"
    }
}

@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var achievements: [AchievementUIModel] = []
    @Published var unlockedCountText: String = "0 / 8"
    @Published var totalProgressFraction: Double = 0.0
    @Published var unlockedCount: Int = 0
    
    private let metricsRepository: MetricsRepository
    private let achievementDefinitions: [(id: String, icon: String)] = [
        ("first_step", "shoeprints.fill"),
        ("active_user", "person.text.rectangle.fill"),
        ("week_streak", "flame.fill"),
        ("ninja_sorting", "bolt.shield.fill"),
        ("early_bird", "sun.max.fill"),
        ("eco_weekend", "sparkles"),
        ("master_informer", "doc.badge.gearshape.fill"),
        ("eco_addict", "globe.europe.africa.fill")
    ]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale.current
        return formatter
    }()
    
    init(metricsRepository: MetricsRepository) {
        self.metricsRepository = metricsRepository
        self.loadAchievements()
    }
    
    func loadAchievements() {
        var tempModels: [AchievementUIModel] = []
        var unlockedCounter = 0
        
        for definition in achievementDefinitions {
            let progress = metricsRepository.getAchievementProgress(id: definition.id)
            let isUnlocked = progress.current >= progress.goal
            
            if isUnlocked { unlockedCounter += 1 }
            var dateText: String? = nil
            if isUnlocked {
                let unlockDate = metricsRepository.getAchievementUnlockDate(id: definition.id) ?? Date()
                let dateString = dateFormatter.string(from: unlockDate)
                let statusPrefix = String(localized: "achievement_unlocked_status")
                dateText = "\(statusPrefix) \(dateString)"
            }
            
            let model = AchievementUIModel(
                id: definition.id,
                title: String(localized: LocalizedStringResource(stringLiteral: "achievement_\(definition.id)_title")),
                description: String(localized: LocalizedStringResource(stringLiteral: "achievement_\(definition.id)_desc")),
                icon: definition.icon,
                currentValue: progress.current,
                goalValue: progress.goal,
                isUnlocked: isUnlocked,
                unlockDateText: dateText
            )
            tempModels.append(model)
        }
        
        self.achievements = tempModels
        self.unlockedCountText = "\(unlockedCounter) / \(achievementDefinitions.count)"
        self.totalProgressFraction = Double(unlockedCounter) / Double(achievementDefinitions.count)
        self.unlockedCount = unlockedCounter
    }
}
