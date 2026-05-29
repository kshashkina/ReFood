import Foundation
import UIKit

protocol EmailServiceProtocol {
    func sendSupportEmail(to address: String)
}

final class URLEmailService: EmailServiceProtocol {
    func sendSupportEmail(to address: String) {
        guard let url = URL(string: "mailto:\(address)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
