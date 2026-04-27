import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var vm: MapViewModel
    let showLocationWarning: Bool
    let onRequestLocationAccess: () -> Void
    
    init(repository: LocationRepository, networkMonitor: NetworkMonitor, locationService: LocationServiceProtocol, showLocationWarning: Bool, onRequestLocationAccess: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: MapViewModel(repository: repository, networkMonitor: networkMonitor, locationService: locationService))
        self.showLocationWarning = showLocationWarning
        self.onRequestLocationAccess = onRequestLocationAccess
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            
            VStack(spacing: 0) {
                MapTopBarView(filters: vm.filters, selectedFilter: $vm.selectedFilter)
                
                if vm.isFetching {
                    MapLoaderView().transition(.move(edge: .top).combined(with: .opacity))
                } else if vm.showSearchButton {
                    MapSearchAreaButton { vm.performSearchInArea() }
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else if vm.showNoPointsToast {
                    MapNoPointsToast().transition(.move(edge: .top).combined(with: .opacity))
                } else if vm.showNoRouteToast {
                    MapNoRouteToast().transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                if let route = vm.route {
                    RouteInfoBanner(
                        route: route,
                        formattedTime: vm.getFormattedTime(route.time),
                        formattedDistance: vm.getFormattedDistance(route.distance)
                    ) { vm.clearRoute() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            floatingButtonsLayer
        }
        .onAppear { vm.onAppear() }
        .onChange(of: vm.selectedFilter) { _ in vm.onFilterChange() }
        .onChange(of: vm.showLocationSettings) { _, show in
            if show {
                onRequestLocationAccess()
                vm.showLocationSettings = false
            }
        }
        .sheet(item: $vm.selectedPoint) { point in
            MapPointDetailsSheet(
                point: point,
                displayName: vm.getDisplayName(for: point),
                loadingMode: vm.loadingRouteMode,
                formatMaterial: { vm.formatMaterialName($0) },
                onGetRoute: { mode in vm.buildRoute(to: point, mode: mode) } 
            )
            .presentationDetents([.fraction(MapConstants.UI.sheetDetentFraction), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $vm.showNoInternet) {
            NoInternetSheet { vm.showNoInternet = false }.presentationDetents([.height(360)])
        }
    }
    
    private var mapLayer: some View {
        Map(position: $vm.position) {
            UserAnnotation()
            
            if let route = vm.route {
                MapPolyline(coordinates: route.polylineCoordinates)
                    .stroke(Color.appAccent, lineWidth: 5)
            }
            
            ForEach(vm.locations) { point in
                Annotation(vm.getDisplayName(for: point), coordinate: point.coordinate) {
                    MapMarkerIcon()
                        .opacity(vm.isPointFaded(point) ? 0.4 : 1.0)
                        .scaleEffect(vm.isPointFaded(point) ? 0.8 : 1.0)
                        .animation(.easeInOut, value: vm.isPointFaded(point))
                        .onTapGesture {
                            if vm.routedPoint == nil {
                                vm.selectedPoint = point
                            }
                        }
                }
            }
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .ignoresSafeArea()
        .onMapCameraChange(frequency: .onEnd) { vm.onCameraChange(context: $0) }
        .simultaneousGesture(DragGesture(minimumDistance: 1).onChanged { _ in vm.handleUserInteraction() })
        .simultaneousGesture(MagnifyGesture().onChanged { _ in vm.handleUserInteraction() })
        .simultaneousGesture(RotateGesture().onChanged { _ in vm.handleUserInteraction() })
    }
    
    private var floatingButtonsLayer: some View {
        VStack {
            if showLocationWarning {
                MapLocationRequestButton(action: onRequestLocationAccess)
            } else {
                MapTrackingButton(mode: vm.trackingMode) { vm.toggleTracking() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 16)
        .padding(.top, MapConstants.UI.buttonsTopOffset)
    }
}
