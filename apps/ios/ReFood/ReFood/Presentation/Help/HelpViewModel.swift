import Foundation
import SwiftUI
import Combine

struct FAQItem: Identifiable {
    let id = UUID()
    let index: Int
    let question: String
    let answer: String
}

@MainActor
final class HelpViewModel: ObservableObject {
    @Published var expandedItemId: UUID? = nil
    
    let faqItems: [FAQItem]
    private let emailService: EmailServiceProtocol
    
    init(emailService: EmailServiceProtocol) {
        self.emailService = emailService
        
        self.faqItems = [
            FAQItem(index: 1, question: String(localized: "help_faq_q1"), answer: String(localized: "help_faq_a1")),
            FAQItem(index: 2, question: String(localized: "help_faq_q2"), answer: String(localized: "help_faq_a2")),
            FAQItem(index: 3, question: String(localized: "help_faq_q3"), answer: String(localized: "help_faq_a3")),
            FAQItem(index: 4, question: String(localized: "help_faq_q4"), answer: String(localized: "help_faq_a4")),
            FAQItem(index: 5, question: String(localized: "help_faq_q5"), answer: String(localized: "help_faq_a5")),
            FAQItem(index: 6, question: String(localized: "help_faq_q6"), answer: String(localized: "help_faq_a6"))
        ]
    }
    
    func toggleItem(_ item: FAQItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if expandedItemId == item.id {
                expandedItemId = nil
            } else {
                expandedItemId = item.id
            }
        }
    }
    
    func contactSupport() {
        emailService.sendSupportEmail(to: "kayara.tech.team@gmail.com")
    }
}
