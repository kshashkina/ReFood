import Foundation

enum OnboardingEvent: AnalyticsEventProtocol {
    case firstLaunch
    case appLaunch
    case screenView(step: Int)
    case continueTap(step: Int)
    
    var name: String {
        switch self {
        case .firstLaunch: return "first_launch"
        case .appLaunch: return "app_launch"
        case .screenView(let step): return "\(prefix(for: step))_onboarding_screen_view"
        case .continueTap(let step): return "\(prefix(for: step))_onboarding_continue_tap"
        }
    }
    
    private func prefix(for step: Int) -> String {
        switch step {
        case 1: return "first"
        case 2: return "second"
        case 3: return "third"
        default: return "unknown"
        }
    }
}
