import SwiftUI
import MapKit
import CoreLocation
import Combine

enum RouteMode: String {
    case walk, bicycle, drive
}

enum FilterType: String, CaseIterable {
    case all = "filter_all"
    case plastic = "filter_plastic"
    case glass = "filter_glass"
    case paper = "filter_paper"
    case metal = "filter_metal"
    case cardboard = "filter_cardboard"
    case batteries = "filter_batteries"
    case clothing = "filter_clothing"
}

@MainActor
final class MapViewModel: ObservableObject {
    enum TrackingMode {
        case none, location, heading
    }
    
    @Published private(set) var locations: [MapPoint] = []
    @Published private(set) var isFetching: Bool = false
    @Published private(set) var showNoPointsToast: Bool = false
    @Published private(set) var showNoRouteToast: Bool = false
    @Published private(set) var route: MapRoute? = nil
    @Published private(set) var isBuildingRoute: Bool = false
    @Published private(set) var routedPoint: MapPoint? = nil
    @Published private(set) var loadingRouteMode: RouteMode? = nil
    
    @Published var selectedFilter: String = FilterType.all.rawValue
    @Published var showSearchButton: Bool = false
    @Published var selectedPoint: MapPoint? = nil
    @Published var showNoInternet: Bool = false
    @Published var showLocationSettings: Bool = false
    @Published var trackingMode: TrackingMode = .none
    @Published var isAnimatingCamera: Bool = false
    @Published var position: MapCameraPosition = .userLocation(
        fallback: .camera(MapCamera(centerCoordinate: MapConstants.kyivCenter, distance: MapConstants.defaultZoom, heading: 0, pitch: 0))
    )
    
    var currentCamera: MapCamera? = nil
    var currentMapCenter: CLLocationCoordinate2D? = nil
    private var lastFetchedCenter: CLLocationCoordinate2D? = nil
    private var currentFetchTask: Task<Void, Never>?
    private var currentRouteTask: Task<Void, Never>?
    
    let filters = FilterType.allCases.map { $0.rawValue }
    
    private let repository: LocationRepository
    private let networkMonitor: NetworkMonitor
    private let locationService: LocationServiceProtocol

    init(repository: LocationRepository, networkMonitor: NetworkMonitor, locationService: LocationServiceProtocol) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        self.locationService = locationService
    }
    
    func onAppear() {
        locationService.startUpdating()
        trackingMode = .location
    }
    
    func handleUserInteraction() {
        if !isAnimatingCamera && trackingMode != .none {
            trackingMode = .none
        }
    }
    
    func toggleTracking() {
        switch trackingMode {
        case .none:
            trackingMode = .location
            resetToNorthAndFollow()
        case .location:
            trackingMode = .heading
            animateToHeading()
        case .heading:
            trackingMode = .location
            resetToNorthAndFollow()
        }
    }
    
    private func animateToHeading() {
        isAnimatingCamera = true
        let currentDist = currentCamera?.distance ?? MapConstants.defaultZoom
        let target = MapCamera(centerCoordinate: locationService.currentLocation?.coordinate ?? MapConstants.kyivCenter, distance: currentDist, heading: currentCamera?.heading ?? 0, pitch: 45)
        
        withAnimation(.easeInOut(duration: MapConstants.Animation.toggleHeading)) {
            position = .userLocation(followsHeading: true, fallback: .camera(target))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.isAnimatingCamera = false }
    }
    
    private func resetToNorthAndFollow() {
        isAnimatingCamera = true
        guard let userLoc = locationService.currentLocation?.coordinate else {
            isAnimatingCamera = false
            return
        }
        let currentDist = currentCamera?.distance ?? MapConstants.defaultZoom
        let targetDist = min(max(currentDist, MapConstants.minFlightZoom), MapConstants.maxFlightZoom)
        let target = MapCamera(centerCoordinate: userLoc, distance: targetDist, heading: 0, pitch: 0)
    
        withAnimation(.easeInOut(duration: 1.0)) {
            position = .userLocation(followsHeading: false, fallback: .camera(target))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isAnimatingCamera = false
        }
    }
    
    func onCameraChange(context: MapCameraUpdateContext) {
        currentMapCenter = context.region.center
        currentCamera = context.camera
        
        if lastFetchedCenter == nil {
            fetchData(center: context.region.center)
        } else if let lastCenter = lastFetchedCenter {
            let dist = CLLocation(latitude: context.region.center.latitude, longitude: context.region.center.longitude)
                .distance(from: CLLocation(latitude: lastCenter.latitude, longitude: lastCenter.longitude))
            
            if dist > MapConstants.fetchThreshold {
                if trackingMode != .none {
                    fetchData(center: context.region.center)
                } else {
                    withAnimation(.spring()) { showSearchButton = true }
                }
            }
        }
    }
    
    func buildRoute(to point: MapPoint, mode: RouteMode = .walk) {
        currentRouteTask?.cancel()
        
        currentRouteTask = Task {
            if !(await networkMonitor.waitForConnectionStatus()) {
                if !Task.isCancelled { selectedPoint = nil; showNoInternet = true }
                return
            }
            
            guard let from = locationService.currentLocation?.coordinate else {
                if !Task.isCancelled { selectedPoint = nil; showLocationSettings = true }
                return
            }

            if Task.isCancelled { return }

            isBuildingRoute = true
            loadingRouteMode = mode
            
            do {
                let fetchedRoute = try await repository.getRoute(from: from, to: point.coordinate, mode: mode.rawValue)
                
                if Task.isCancelled { return }
                
                withAnimation(.spring()) {
                    self.route = fetchedRoute
                    self.routedPoint = point
                    self.selectedPoint = nil
                    self.isBuildingRoute = false
                    self.loadingRouteMode = nil
                    focusOnRoute(fetchedRoute)
                }
            } catch {
                if !Task.isCancelled {
                    withAnimation {
                        self.isBuildingRoute = false
                        self.loadingRouteMode = nil
                        self.selectedPoint = nil
                        self.showNoRouteToast = true
                    }
                    
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if !Task.isCancelled {
                        withAnimation { self.showNoRouteToast = false }
                    }
                }
            }
        }
    }

    private func focusOnRoute(_ route: MapRoute) {
        let coords = route.polylineCoordinates
        guard !coords.isEmpty else { return }
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2, longitude: (lons.min()! + lons.max()!) / 2),
            span: MKCoordinateSpan(latitudeDelta: (max(lats.max()! - lats.min()!, 0.005)) * 2.2, longitudeDelta: (max(lons.max()! - lons.min()!, 0.005)) * 1.8)
        )
        
        trackingMode = .none
        withAnimation(.easeInOut(duration: MapConstants.Animation.focusRoute)) { position = .region(region) }
    }
    
    private func fetchData(center: CLLocationCoordinate2D) {
        currentFetchTask?.cancel()
        
        currentFetchTask = Task {
            guard await networkMonitor.waitForConnectionStatus() else {
                if !Task.isCancelled { showNoInternet = true }
                return
            }
            
            if Task.isCancelled { return }
            
            withAnimation {
                showSearchButton = false
                showNoPointsToast = false
                isFetching = true
            }
            lastFetchedCenter = center
            
            do {
                let filter = selectedFilter.replacingOccurrences(of: "filter_", with: "")
                let newLocations = try await repository.getLocations(lat: center.latitude, lon: center.longitude, materials: filter)
                
                if Task.isCancelled { return }
                
                withAnimation {
                    self.locations = newLocations
                    self.isFetching = false
                    if newLocations.isEmpty {
                        self.showNoPointsToast = true
                    }
                }
                
                if newLocations.isEmpty {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if !Task.isCancelled {
                        withAnimation { self.showNoPointsToast = false }
                    }
                }
            } catch {
                if !Task.isCancelled {
                    withAnimation { self.isFetching = false }
                }
            }
        }
    }
    
    func clearRoute() { withAnimation { route = nil; routedPoint = nil } }
    func performSearchInArea() { if let center = currentMapCenter { fetchData(center: center) } }
    func onFilterChange() { if let center = currentMapCenter { fetchData(center: center) } }
    func getFormattedDistance(_ m: Double) -> String { RouteFormatter.distance(m) }
    func getFormattedTime(_ s: Double) -> String { RouteFormatter.time(s) }
    
    func getDisplayName(for point: MapPoint) -> String {
        let lowercasedName = point.name.lowercased()
        if point.name.isEmpty || lowercasedName == "no name" || lowercasedName == "recycling point" {
            return String(localized: "map_default_point_name")
        }
        return point.name
    }
    
    func isPointFaded(_ point: MapPoint) -> Bool {
        if let selected = selectedPoint { return selected.id != point.id }
        if let routed = routedPoint { return routed.id != point.id }
        return false
    }
    
    func formatMaterialName(_ material: String) -> String {
        let key = "filter_\(material.lowercased().replacingOccurrences(of: " ", with: "_"))"
        let fallback = material.replacingOccurrences(of: "_", with: " ").capitalized
        let localized = NSLocalizedString(key, comment: "")
        return localized == key ? fallback : localized
    }
}
