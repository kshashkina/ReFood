import XCTest
import MapKit
import CoreLocation
@testable import ReFood

@MainActor
final class MapViewModelTests: XCTestCase {
    
    var sut: MapViewModel!
    var mockRepository: MockLocationRepository!
    var mockNetworkMonitor: MockNetworkMonitor!
    var mockLocationService: MockLocationService!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockLocationRepository()
        mockNetworkMonitor = MockNetworkMonitor()
        mockLocationService = MockLocationService()
        sut = makeSUT()
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockNetworkMonitor = nil
        mockLocationService = nil
        super.tearDown()
    }
    
    func test_onAppear_shouldStartUpdatingLocation() {
        sut.onAppear()
        
        XCTAssertTrue(mockLocationService.startUpdatingCalled)
    }
    
    func test_onAppear_shouldSetTrackingModeToLocation() {
        sut.trackingMode = .none
        
        sut.onAppear()
        
        XCTAssertEqual(sut.trackingMode, .location)
    }
    
    func test_handleUserInteraction_whenAnimatingCamera_shouldNotDisableTracking() {
        sut.trackingMode = .location
        sut.isAnimatingCamera = true
        
        sut.handleUserInteraction()
        
        XCTAssertEqual(sut.trackingMode, .location)
    }
    
    func test_handleUserInteraction_whenNotAnimatingCamera_shouldDisableTracking() {
        sut.trackingMode = .location
        sut.isAnimatingCamera = false
        
        sut.handleUserInteraction()
        
        XCTAssertEqual(sut.trackingMode, .none)
    }
    
    func test_toggleTracking_whenModeIsNone_shouldSwitchToLocation() {
        sut.trackingMode = .none
        
        sut.toggleTracking()
        
        XCTAssertEqual(sut.trackingMode, .location)
    }
    
    func test_toggleTracking_whenModeIsLocation_shouldSwitchToHeading() {
        sut.trackingMode = .location
        
        sut.toggleTracking()
        
        XCTAssertEqual(sut.trackingMode, .heading)
    }
    
    func test_toggleTracking_whenModeIsHeading_shouldSwitchToLocation() {
        sut.trackingMode = .heading
        
        sut.toggleTracking()
        
        XCTAssertEqual(sut.trackingMode, .location)
    }
    
    func test_buildRoute_whenNoInternet_shouldShowNoInternet() async {
        mockNetworkMonitor.isConnected = false
        let point = createMockPoint()
        
        sut.buildRoute(to: point, mode: .walk)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(sut.showNoInternet)
        XCTAssertNil(sut.route)
    }
    
    func test_buildRoute_whenLocationIsNil_shouldShowLocationSettings() async {
        mockNetworkMonitor.isConnected = true
        mockLocationService.currentLocation = nil
        let point = createMockPoint()
        
        sut.buildRoute(to: point, mode: .walk)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(sut.showLocationSettings)
        XCTAssertNil(sut.route)
    }
    
    func test_buildRoute_success_shouldSetRouteAndRoutedPoint() async {
        mockNetworkMonitor.isConnected = true
        mockLocationService.currentLocation = CLLocation(latitude: 50.45, longitude: 30.52)
        mockRepository.mockRoute = createMockRoute(mode: "walk")
        let point = createMockPoint(id: "point_1")
        
        sut.buildRoute(to: point, mode: .walk)
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertNotNil(sut.route)
        XCTAssertEqual(sut.routedPoint?.id, point.id)
        XCTAssertFalse(sut.isBuildingRoute)
        XCTAssertNil(sut.loadingRouteMode)
        XCTAssertNil(sut.selectedPoint)
    }
    
    func test_buildRoute_failure_shouldShowNoRouteToast() async {
        mockNetworkMonitor.isConnected = true
        mockRepository.shouldThrowRouteError = true
        let point = createMockPoint()
        
        sut.buildRoute(to: point, mode: .drive)
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertTrue(sut.showNoRouteToast)
        XCTAssertFalse(sut.isBuildingRoute)
        XCTAssertNil(sut.loadingRouteMode)
    }
    
    func test_performSearchInArea_success_shouldSetLocationsAndStopFetching() async {
        mockNetworkMonitor.isConnected = true
        sut.currentMapCenter = CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52)
        mockRepository.mockLocations = [
            createMockPoint(name: "Point 1"),
            createMockPoint(name: "Point 2")
        ]
        
        sut.performSearchInArea()
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertEqual(sut.locations.count, 2)
        XCTAssertFalse(sut.isFetching)
        XCTAssertFalse(sut.showNoPointsToast)
    }
    
    func test_performSearchInArea_whenNoPoints_shouldStopFetchingAndShowToast() async {
        mockNetworkMonitor.isConnected = true
        sut.currentMapCenter = CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52)
        mockRepository.mockLocations = []
        
        sut.performSearchInArea()
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertTrue(sut.locations.isEmpty)
        XCTAssertFalse(sut.isFetching)
        XCTAssertTrue(sut.showNoPointsToast)
    }
    
    func test_performSearchInArea_whenNoInternet_shouldShowNoInternet() async {
        mockNetworkMonitor.isConnected = false
        sut.currentMapCenter = CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52)
        
        sut.performSearchInArea()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(sut.showNoInternet)
    }
    
    func test_onFilterChange_shouldFetchLocationsForCurrentCenter() async {
        mockNetworkMonitor.isConnected = true
        sut.currentMapCenter = CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52)
        mockRepository.mockLocations = [createMockPoint()]
        sut.selectedFilter = FilterType.plastic.rawValue
        
        sut.onFilterChange()
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertEqual(mockRepository.receivedMaterials, "plastic")
        XCTAssertEqual(sut.locations.count, 1)
    }
    
    func test_clearRoute_shouldRemoveRouteAndRoutedPoint() async {
        mockNetworkMonitor.isConnected = true
        mockRepository.mockRoute = createMockRoute(mode: "walk")
        let point = createMockPoint(id: "point_1")
        
        sut.buildRoute(to: point, mode: .walk)
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        sut.clearRoute()
        
        XCTAssertNil(sut.route)
        XCTAssertNil(sut.routedPoint)
    }
    
    func test_getDisplayName_whenNameIsEmpty_shouldReturnDefaultLocalizedName() {
        let point = createMockPoint(name: "")
        
        XCTAssertEqual(sut.getDisplayName(for: point), String(localized: "map_default_point_name"))
    }
    
    func test_getDisplayName_whenNameIsNoName_shouldReturnDefaultLocalizedName() {
        let point = createMockPoint(name: "No name")
        
        XCTAssertEqual(sut.getDisplayName(for: point), String(localized: "map_default_point_name"))
    }
    
    func test_getDisplayName_whenNameExists_shouldReturnName() {
        let point = createMockPoint(name: "Eco Point")
        
        XCTAssertEqual(sut.getDisplayName(for: point), "Eco Point")
    }
    
    func test_isPointFaded_whenAnotherPointIsSelected_shouldReturnTrue() {
        let first = createMockPoint(id: "1")
        let second = createMockPoint(id: "2")
        sut.selectedPoint = first
        
        XCTAssertTrue(sut.isPointFaded(second))
        XCTAssertFalse(sut.isPointFaded(first))
    }
    
    func test_isPointFaded_whenAnotherPointIsRouted_shouldReturnTrue() async {
        mockNetworkMonitor.isConnected = true
        mockLocationService.currentLocation = CLLocation(latitude: 50.45, longitude: 30.52)
        mockRepository.mockRoute = createMockRoute(mode: "walk")
        
        let first = createMockPoint(id: "1")
        let second = createMockPoint(id: "2")
        
        sut.buildRoute(to: first, mode: .walk)
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertTrue(sut.isPointFaded(second))
        XCTAssertFalse(sut.isPointFaded(first))
    }
    
    func test_formatMaterialName_whenLocalizationMissing_shouldReturnCapitalizedFallback() {
        let result = sut.formatMaterialName("mixed_waste")
        
        XCTAssertEqual(result, "Mixed Waste")
    }
    
    func test_getFormattedDistance_shouldUseRouteFormatter() {
        XCTAssertEqual(sut.getFormattedDistance(1500), RouteFormatter.distance(1500))
    }
    
    func test_getFormattedTime_shouldUseRouteFormatter() {
        XCTAssertEqual(sut.getFormattedTime(3600), RouteFormatter.time(3600))
    }
    
    private func makeSUT() -> MapViewModel {
        MapViewModel(
            repository: mockRepository,
            networkMonitor: mockNetworkMonitor,
            locationService: mockLocationService
        )
    }
    
    private func createMockPoint(
        id: String = UUID().uuidString,
        name: String = "Eco Point",
        lat: Double = 50.45,
        lon: Double = 30.52
    ) -> MapPoint {
        MapPoint(
            id: id,
            lat: lat,
            lon: lon,
            name: name,
            info: MapPointInfo(
                address: "Test Address",
                operatorName: "Test Operator"
            ),
            details: MapPointDetails(
                acceptedMaterials: ["plastic", "glass"]
            )
        )
    }
    
    private func createMockRoute(mode: String) -> MapRoute {
        MapRoute(
            mode: mode,
            distance: 1200,
            distanceUnits: "meters",
            time: 900,
            steps: [
                RouteStep(
                    distance: 1200,
                    time: 900,
                    instruction: "Go straight"
                )
            ],
            coordinates: [
                RouteCoordinate(lat: 50.45, lon: 30.52),
                RouteCoordinate(lat: 50.46, lon: 30.53)
            ]
        )
    }
}

final class MockNetworkMonitor: NetworkMonitoring {
    var isConnected = true
    
    func waitForConnectionStatus() async -> Bool {
        isConnected
    }
}

final class MockLocationService: LocationServiceProtocol {
    var currentLocation: CLLocation? = CLLocation(latitude: 50.45, longitude: 30.52)
    var startUpdatingCalled = false
    var requestAuthorizationCalled = false
    
    func requestAuthorization() {
        requestAuthorizationCalled = true
    }
    
    func startUpdating() {
        startUpdatingCalled = true
    }
}

final class MockLocationRepository: LocationRepository {
    var mockLocations: [MapPoint] = []
    var mockRoute: MapRoute?
    var shouldThrowLocationsError = false
    var shouldThrowRouteError = false
    var receivedMaterials: String?
    
    func getLocations(lat: Double, lon: Double, materials: String?) async throws -> [MapPoint] {
        receivedMaterials = materials
        
        if shouldThrowLocationsError {
            throw NSError(domain: "LocationError", code: 1)
        }
        
        return mockLocations
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, mode: String) async throws -> MapRoute {
        if shouldThrowRouteError {
            throw NSError(domain: "RouteError", code: 1)
        }
        
        guard let mockRoute else {
            throw NSError(domain: "RouteError", code: 404)
        }
        
        return mockRoute
    }
}
