import Foundation
@testable import ReFood

final class MockEmailService: EmailServiceProtocol {
    var sendSupportEmailCalled = false
    var receivedAddress: String?
    
    func sendSupportEmail(to address: String) {
        sendSupportEmailCalled = true
        receivedAddress = address
    }
}
