import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var vm: MapViewModel
    @Binding var externalFilter: String
    let showLocationWarning: Bool
    let onRequestLocationAccess: () -> Void
    
    let analytics: AnalyticsServiceProtocol
    
    init(
        repository: LocationRepository,
        networkMonitor: NetworkMonitoring,
        locationService: LocationServiceProtocol,
        metricsRepository: MetricsRepositoryProtocol,
        showLocationWarning: Bool,
        externalFilter: Binding<String>,
        analytics: AnalyticsServiceProtocol,
        onRequestLocationAccess: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: MapViewModel(
            repository: repository,
            networkMonitor: networkMonitor,
            locationService: locationService,
            metricsRepository: metricsRepository
        ))
        self._externalFilter = externalFilter
        self.showLocationWarning = showLocationWarning
        self.analytics = analytics
        self.onRequestLocationAccess = onRequestLocationAccess
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            
            VStack(spacing: 0) {
                MapTopBarView(
                    filters: vm.filters,
                    selectedFilter: $vm.selectedFilter,
                    onFilterTap: { filter in
                        analytics.track(MapEvent.filterTap(filter: filter))
                    }
                )
                
                if vm.isFetching {
                    MapLoaderView().transition(.move(edge: .top).combined(with: .opacity))
                } else if vm.showSearchButton {
                    MapSearchAreaButton {
                        analytics.track(MapEvent.searchTap)
                        vm.performSearchInArea()
                    }
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
                    ) {
                        analytics.track(MapEvent.routeCloseTap)
                        vm.clearRoute()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            floatingButtonsLayer
        }
        .onAppear {
            analytics.track(MapEvent.screenView)
            vm.selectedFilter = externalFilter
            vm.onAppear()
        }
        .onChange(of: vm.selectedFilter) { newValue in
            if externalFilter != newValue { externalFilter = newValue }
            vm.onFilterChange()
        }
        .onChange(of: externalFilter) { newValue in
            if vm.selectedFilter != newValue { vm.selectedFilter = newValue }
        }
        .onChange(of: vm.showLocationSettings) { _, show in
            if show {
                onRequestLocationAccess()
                vm.showLocationSettings = false
            }
        }
        .sheet(item: $vm.selectedPoint, onDismiss: {
            if vm.routedPoint == nil {
                analytics.track(MapEvent.pointCloseTap)
            }
        }) { point in
            MapPointDetailsSheet(
                point: point,
                displayName: vm.getDisplayName(for: point),
                loadingMode: vm.loadingRouteMode,
                formatMaterial: { vm.formatMaterialName($0) },
                onGetRoute: { mode in
                    analytics.track(MapEvent.pointRouteTap(type: mode.rawValue))
                    vm.buildRoute(to: point, mode: mode)
                }
            )
            .presentationDetents([.fraction(MapConstants.UI.sheetDetentFraction), .large])
            .presentationDragIndicator(.visible)
            .onAppear {
                analytics.track(MapEvent.pointModalView)
            }
        }
        .sheet(isPresented: $vm.showNoInternet) {
            NoInternetSheet {
                analytics.track(NoInternetEvent.noInternetOkTap)
                vm.showNoInternet = false
            }
            .onAppear {
                analytics.track(NoInternetEvent.noInternetModalView)
            }
            .presentationDetents([.height(360)])
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
                                analytics.track(MapEvent.pointTap)
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
                MapTrackingButton(mode: vm.trackingMode) {
                    let flow = (vm.trackingMode == .location) ? "follow" : "center"
                    analytics.track(MapEvent.centerTap(flow: flow))
                    vm.toggleTracking()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 16)
        .padding(.top, MapConstants.UI.buttonsTopOffset)
    }
}
