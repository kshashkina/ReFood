import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var vm: MapViewModel
    
    let showLocationWarning: Bool
    let onRequestLocationAccess: () -> Void
    
    init(
        repository: LocationRepository,
        networkMonitor: NetworkMonitor,
        showLocationWarning: Bool,
        onRequestLocationAccess: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: MapViewModel(repository: repository, networkMonitor: networkMonitor))
        self.showLocationWarning = showLocationWarning
        self.onRequestLocationAccess = onRequestLocationAccess
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $vm.position) {
                UserAnnotation()
                
                ForEach(vm.locations) { point in
                    Annotation(vm.getDisplayName(for: point), coordinate: point.coordinate) {
                        MapMarkerIcon()
                            .onTapGesture {
                                vm.selectedPoint = point
                            }
                    }
                }
            }
            .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
            .ignoresSafeArea()
            .onMapCameraChange(frequency: .onEnd) { context in
                vm.onCameraChange(newCenter: context.region.center)
            }
            
            VStack(spacing: 0) {
                MapTopBarView(filters: vm.filters, selectedFilter: $vm.selectedFilter)
                
                if vm.isFetching {
                    MapLoaderView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else if vm.showSearchButton {
                    MapSearchAreaButton(action: vm.performSearchInArea)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                HStack {
                    Spacer()
                    if showLocationWarning {
                        MapLocationRequestButton(action: onRequestLocationAccess)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .onChange(of: vm.selectedFilter) { _ in
            vm.onFilterChange()
        }
        .sheet(item: $vm.selectedPoint) { point in
            MapPointDetailsSheet(point: point, displayName: vm.getDisplayName(for: point))
                .presentationDetents([.fraction(0.35), .medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $vm.showNoInternet) {
            NoInternetSheet {
                vm.showNoInternet = false
            }
            .presentationDetents([.height(360)])
        }
    }
}
