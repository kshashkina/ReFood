import SwiftUI

struct MapToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.9))
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.4), radius: 10)
            .padding(.top, 12)
    }
}

extension View {
    func mapToastStyle() -> some View {
        self.modifier(MapToastModifier())
    }
}

struct MapTopBarView: View {
    let filters: [String]
    @Binding var selectedFilter: String
    var onFilterTap: (String) -> Void
    
    var body: some View {
        LinearGradient(colors: [.black, .black.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom)
            .frame(height: 180)
            .overlay(
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey("map_title"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                MapFilterChip(title: filter, isSelected: selectedFilter == filter) {
                                    withAnimation(.spring()) { selectedFilter = filter }
                                    onFilterTap(filter)
                                }
                            }
                        }.padding(.horizontal, 24)
                    }
                }.padding(.top, 60)
            )
    }
}

struct MapFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(ZStack { Color.black; if isSelected { Color.appAccent.opacity(0.15) } })
                .foregroundColor(isSelected ? Color.appAccent : .white.opacity(0.6))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color.appAccent : Color.white.opacity(0.1), lineWidth: 1.5))
        }.buttonStyle(.plain)
    }
}

struct MapSearchAreaButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .bold))
                Text(LocalizedStringKey("map_btn_search_area"))
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(Color.appAccent)
            .mapToastStyle()
        }
    }
}

struct MapLoaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            SpinnerCircle()
            Text(LocalizedStringKey("map_lbl_searching"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .mapToastStyle()
    }
}

struct MapNoPointsToast: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 14))
            Text(LocalizedStringKey("map_lbl_no_points"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .mapToastStyle()
    }
}

struct MapNoRouteToast: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
            Text(LocalizedStringKey("map_lbl_no_route"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .mapToastStyle()
    }
}

struct MapLocationRequestButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.black.opacity(0.8)).frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.appAccent.opacity(0.5), lineWidth: 1))
                Image(systemName: "location.slash.fill").font(.system(size: 18)).foregroundColor(Color.appAccent)
            }.shadow(color: Color.black.opacity(0.3), radius: 10)
        }
    }
}

struct MapTrackingButton: View {
    let mode: MapViewModel.TrackingMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.black.opacity(0.8)).frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.appAccent.opacity(0.5), lineWidth: 1))
                
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(mode == .none ? .white : Color.appAccent)
            }.shadow(color: Color.black.opacity(0.3), radius: 10)
        }
    }
    
    private var iconName: String {
        switch mode {
        case .none: return "location"
        case .location: return "location.fill"
        case .heading: return "location.north.line.fill"
        }
    }
}

struct SpinnerCircle: View {
    @State private var isSpinning = false
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1.0)
            .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .frame(width: 16, height: 16)
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isSpinning = true
                }
            }
    }
}

struct MapMarkerIcon: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.appAccent).frame(width: 30, height: 30).shadow(color: Color.appAccent.opacity(0.5), radius: 5)
            Image(systemName: "leaf.fill").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
        }
    }
}

struct MapPointDetailsSheet: View {
    let point: MapPoint
    let displayName: String
    let loadingMode: RouteMode?
    let formatMaterial: (String) -> String
    let onGetRoute: (RouteMode) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(displayName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let address = point.info.address {
                HStack(alignment: .top) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color.appAccent)
                    Text(address)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text(LocalizedStringKey("map_sheet_materials"))
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(point.details.acceptedMaterials, id: \.self) { material in
                        Text(formatMaterial(material))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appAccent.opacity(0.15))
                            .foregroundColor(Color.appAccent)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text(LocalizedStringKey("map_get_route_title"))
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    RouteModeButton(icon: "figure.walk", locKey: "route_mode_walk", isLoading: loadingMode == .walk, action: { onGetRoute(.walk) })
                    RouteModeButton(icon: "bicycle", locKey: "route_mode_bicycle", isLoading: loadingMode == .bicycle, action: { onGetRoute(.bicycle) })
                    RouteModeButton(icon: "car.fill", locKey: "route_mode_drive", isLoading: loadingMode == .drive, action: { onGetRoute(.drive) })
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black)
        .presentationBackground(Color.black)
    }
}

struct RouteModeButton: View {
    let icon: String
    let locKey: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                }
                
                Text(LocalizedStringKey(locKey))
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color.appAccent)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct RouteInfoBanner: View {
    let route: MapRoute
    let formattedTime: String
    let formattedDistance: String
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconForMode(route.mode))
                .font(.title2)
                .foregroundColor(Color.appAccent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedTime)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(formattedDistance)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 140)
    }
    
    private func iconForMode(_ mode: String) -> String {
        switch mode.lowercased() {
        case "bicycle": return "bicycle"
        case "drive": return "car.fill"
        default: return "figure.walk"
        }
    }
}
