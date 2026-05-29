import XCTest
@testable import ReFood

@MainActor
final class HelpViewModelTests: XCTestCase {
    
    var sut: HelpViewModel!
    var mockEmailService: MockEmailService!
    
    override func setUp() {
        super.setUp()
        mockEmailService = MockEmailService()
        sut = HelpViewModel(emailService: mockEmailService)
    }
    
    override func tearDown() {
        sut = nil
        mockEmailService = nil
        super.tearDown()
    }
    
    func test_init_shouldCreateSixFAQItems() {
        XCTAssertEqual(sut.faqItems.count, 6)
    }
    
    func test_init_shouldStartWithNoExpandedItem() {
        XCTAssertNil(sut.expandedItemId)
    }
    
    func test_toggleItem_whenItemIsCollapsed_shouldExpandItem() {
        let item = sut.faqItems.first!
        
        sut.toggleItem(item)
        
        XCTAssertEqual(sut.expandedItemId, item.id)
    }
    
    func test_toggleItem_whenSameItemIsExpanded_shouldCollapseItem() {
        let item = sut.faqItems.first!
        
        sut.toggleItem(item)
        sut.toggleItem(item)
        
        XCTAssertNil(sut.expandedItemId)
    }
    
    func test_toggleItem_whenAnotherItemIsExpanded_shouldSwitchExpandedItem() {
        let firstItem = sut.faqItems[0]
        let secondItem = sut.faqItems[1]
        
        sut.toggleItem(firstItem)
        sut.toggleItem(secondItem)
        
        XCTAssertEqual(sut.expandedItemId, secondItem.id)
        XCTAssertNotEqual(sut.expandedItemId, firstItem.id)
    }
    
    func test_contactSupport_shouldCallEmailService() {
        sut.contactSupport()
        
        XCTAssertTrue(mockEmailService.sendSupportEmailCalled)
    }
    
    func test_contactSupport_shouldSendCorrectEmailAddress() {
        sut.contactSupport()
        
        XCTAssertEqual(
            mockEmailService.receivedAddress,
            "kayara.tech.team@gmail.com"
        )
    }
    
    func test_faqItems_shouldContainNonEmptyQuestions() {
        XCTAssertTrue(
            sut.faqItems.allSatisfy { !$0.question.isEmpty }
        )
    }
    
    func test_faqItems_shouldContainNonEmptyAnswers() {
        XCTAssertTrue(
            sut.faqItems.allSatisfy { !$0.answer.isEmpty }
        )
    }
    
    func test_faqItems_shouldHaveUniqueIds() {
        let ids = sut.faqItems.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count)
    }
}
