import XCTest
@testable import ReFood

@MainActor
final class AchievementsViewModelTests: XCTestCase {
    
    var sut: AchievementsViewModel!
    var mockMetricsRepository: MockMetricsRepository!
    
    override func setUp() {
        super.setUp()
        mockMetricsRepository = MockMetricsRepository()
    }
    
    override func tearDown() {
        sut = nil
        mockMetricsRepository = nil
        super.tearDown()
    }
    
    func test_init_shouldLoadEightAchievements() {
        sut = makeSUT()
        
        XCTAssertEqual(sut.achievements.count, 8)
    }
    
    func test_init_shouldSetCorrectAchievementIds() {
        sut = makeSUT()
        
        let ids = sut.achievements.map { $0.id }
        
        XCTAssertEqual(ids, [
            "first_step",
            "active_user",
            "week_streak",
            "ninja_sorting",
            "early_bird",
            "eco_weekend",
            "master_informer",
            "eco_addict"
        ])
    }
    
    func test_loadAchievements_whenNoAchievementsUnlocked_shouldSetZeroProgress() {
        sut = makeSUT()
        
        XCTAssertEqual(sut.unlockedCountText, "0 / 8")
        XCTAssertEqual(sut.totalProgressFraction, 0.0)
    }
    
    func test_loadAchievements_whenOneAchievementUnlocked_shouldUpdateUnlockedCountAndProgress() {
        mockMetricsRepository.achievementProgress["first_step"] = (current: 1, goal: 1)
        
        sut = makeSUT()
        
        XCTAssertEqual(sut.unlockedCountText, "1 / 8")
        XCTAssertEqual(sut.totalProgressFraction, 0.125)
    }
    
    func test_loadAchievements_whenAllAchievementsUnlocked_shouldSetFullProgress() {
        let ids = [
            "first_step",
            "active_user",
            "week_streak",
            "ninja_sorting",
            "early_bird",
            "eco_weekend",
            "master_informer",
            "eco_addict"
        ]
        
        ids.forEach {
            mockMetricsRepository.achievementProgress[$0] = (current: 1, goal: 1)
        }
        
        sut = makeSUT()
        
        XCTAssertEqual(sut.unlockedCountText, "8 / 8")
        XCTAssertEqual(sut.totalProgressFraction, 1.0)
    }
    
    func test_loadAchievements_shouldUseProgressFromRepository() {
        mockMetricsRepository.achievementProgress["active_user"] = (current: 4, goal: 10)
        
        sut = makeSUT()
        
        let achievement = sut.achievements.first { $0.id == "active_user" }
        
        XCTAssertEqual(achievement?.currentValue, 4)
        XCTAssertEqual(achievement?.goalValue, 10)
        XCTAssertFalse(achievement?.isUnlocked ?? true)
    }
    
    func test_loadAchievements_whenCurrentEqualsGoal_shouldMarkAchievementAsUnlocked() {
        mockMetricsRepository.achievementProgress["active_user"] = (current: 10, goal: 10)
        
        sut = makeSUT()
        
        let achievement = sut.achievements.first { $0.id == "active_user" }
        
        XCTAssertTrue(achievement?.isUnlocked ?? false)
        XCTAssertNotNil(achievement?.unlockDateText)
    }
    
    func test_loadAchievements_whenCurrentIsGreaterThanGoal_shouldMarkAchievementAsUnlocked() {
        mockMetricsRepository.achievementProgress["active_user"] = (current: 15, goal: 10)
        
        sut = makeSUT()
        
        let achievement = sut.achievements.first { $0.id == "active_user" }
        
        XCTAssertTrue(achievement?.isUnlocked ?? false)
        XCTAssertEqual(achievement?.progressFraction, 1.0)
        XCTAssertEqual(achievement?.percentageText, "100%")
    }
    
    func test_loadAchievements_whenAchievementIsLocked_shouldNotHaveUnlockDateText() {
        mockMetricsRepository.achievementProgress["active_user"] = (current: 3, goal: 10)
        
        sut = makeSUT()
        
        let achievement = sut.achievements.first { $0.id == "active_user" }
        
        XCTAssertFalse(achievement?.isUnlocked ?? true)
        XCTAssertNil(achievement?.unlockDateText)
    }
    
    func test_achievementProgressFraction_shouldCalculateCorrectProgress() {
        let model = AchievementUIModel(
            id: "test",
            title: "Test",
            description: "Desc",
            icon: "star",
            currentValue: 5,
            goalValue: 10,
            isUnlocked: false,
            unlockDateText: nil
        )
        
        XCTAssertEqual(model.progressFraction, 0.5)
    }
    
    func test_achievementProgressFraction_whenCurrentGreaterThanGoal_shouldNotExceedOne() {
        let model = AchievementUIModel(
            id: "test",
            title: "Test",
            description: "Desc",
            icon: "star",
            currentValue: 15,
            goalValue: 10,
            isUnlocked: true,
            unlockDateText: nil
        )
        
        XCTAssertEqual(model.progressFraction, 1.0)
    }
    
    func test_achievementProgressFraction_whenGoalIsZero_shouldReturnZero() {
        let model = AchievementUIModel(
            id: "test",
            title: "Test",
            description: "Desc",
            icon: "star",
            currentValue: 5,
            goalValue: 0,
            isUnlocked: false,
            unlockDateText: nil
        )
        
        XCTAssertEqual(model.progressFraction, 0.0)
    }
    
    func test_percentageText_shouldReturnCorrectPercentage() {
        let model = AchievementUIModel(
            id: "test",
            title: "Test",
            description: "Desc",
            icon: "star",
            currentValue: 3,
            goalValue: 10,
            isUnlocked: false,
            unlockDateText: nil
        )
        
        XCTAssertEqual(model.percentageText, "30%")
    }
    
    func test_loadAchievements_shouldAssignCorrectIcons() {
        sut = makeSUT()
        
        XCTAssertEqual(sut.achievements.first { $0.id == "first_step" }?.icon, "shoeprints.fill")
        XCTAssertEqual(sut.achievements.first { $0.id == "active_user" }?.icon, "person.text.rectangle.fill")
        XCTAssertEqual(sut.achievements.first { $0.id == "week_streak" }?.icon, "flame.fill")
    }
    
    private func makeSUT() -> AchievementsViewModel {
        AchievementsViewModel(metricsRepository: mockMetricsRepository)
    }
}
