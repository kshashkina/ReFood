import SwiftUI
import MapKit
import CoreLocation
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var locations: [MapPoint] = []
    @Published var showSearchButton: Bool = false
    @Published var selectedFilter: String = "filter_all"
    @Published var isFetching: Bool = false
    @Published var selectedPoint: MapPoint? = nil
    
    @Published var showNoInternet: Bool = false
    
    private static let kyivCenter = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
    private let fetchThresholdMeters: CLLocationDistance = 3000
    
    @Published var position: MapCameraPosition = .region(
        MKCoordinateRegion(center: kyivCenter, latitudinalMeters: 5000, longitudinalMeters: 5000)
    )
    
    var currentMapCenter: CLLocationCoordinate2D? = nil
    private var lastFetchedCenter: CLLocationCoordinate2D? = nil
    
    let filters = ["filter_all", "filter_plastic", "filter_glass", "filter_paper", "filter_metal", "filter_cardboard", "filter_batteries", "filter_clothing"]
    
    private let repository: LocationRepository
    private let networkMonitor: NetworkMonitor

    init(repository: LocationRepository, networkMonitor: NetworkMonitor) {
        self.repository = repository
        self.networkMonitor = networkMonitor
    }
    
    func onAppear() {
        position = .userLocation(
            fallback: .region(MKCoordinateRegion(center: Self.kyivCenter, latitudinalMeters: 5000, longitudinalMeters: 5000))
        )
    }
    
    func onCameraChange(newCenter: CLLocationCoordinate2D) {
        currentMapCenter = newCenter
        
        if lastFetchedCenter == nil || locations.isEmpty {
            fetchData(center: newCenter)
        } else if let lastCenter = lastFetchedCenter {
            let newLoc = CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)
            let lastLoc = CLLocation(latitude: lastCenter.latitude, longitude: lastCenter.longitude)
            
            if newLoc.distance(from: lastLoc) > fetchThresholdMeters {
                withAnimation(.spring()) {
                    showSearchButton = true
                }
            }
        }
    }
    
    func onFilterChange() {
        if let center = currentMapCenter {
            fetchData(center: center)
        }
    }
    
    func performSearchInArea() {
        if let center = currentMapCenter {
            fetchData(center: center)
        }
    }
    
    private func fetchData(center: CLLocationCoordinate2D) {
        Task {
            let hasInternet = await networkMonitor.waitForConnectionStatus()
            
            guard hasInternet else {
                self.showNoInternet = true
                return
            }

            withAnimation {
                self.showSearchButton = false
                self.isFetching = true
            }
            self.lastFetchedCenter = center
            
            do {
                let apiFilter = selectedFilter.replacingOccurrences(of: "filter_", with: "")
                let points = try await repository.getLocations(lat: center.latitude, lon: center.longitude, materials: apiFilter)
                
                self.locations = points
                withAnimation { self.isFetching = false }
                
            } catch {
                withAnimation { self.isFetching = false }
                print("DEBUG: \(error)")
            }
        }
    }
    
    func getDisplayName(for point: MapPoint) -> String {
        let lowercasedName = point.name.lowercased()
        if point.name.isEmpty || lowercasedName == "recycling point" {
            return String(localized: "map_default_point_name")
        }
        
        return point.name
    }
}
