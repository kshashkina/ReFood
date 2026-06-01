import Foundation
import AmplitudeSwift

final class AmplitudeAnalyticsService: AnalyticsServiceProtocol {
    static let shared = AmplitudeAnalyticsService()
    
    private let amplitude: Amplitude
    
    private init() {
        self.amplitude = Amplitude(configuration: Configuration(
            apiKey: "77fda66619c4f9af12996254e1e8c1cf",
        ))
    }
    
    func track(_ event: AnalyticsEventProtocol) {
        amplitude.track(eventType: event.name, eventProperties: event.properties)
    }
    
    func setUserId(_ userId: String) {
        amplitude.setUserId(userId: userId)
    }
    
    func resetUser() {
        amplitude.reset()
    }
}
