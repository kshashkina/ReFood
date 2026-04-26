import SwiftUI

struct MapTopBarView: View {
    let filters: [String]
    @Binding var selectedFilter: String
    
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
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.9))
            .foregroundColor(Color.appAccent)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.4), radius: 10)
        }
        .padding(.top, 12)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.9))
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.4), radius: 10)
        .padding(.top, 12)
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
                        Text(formattedMaterialName(material))
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
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black)
        .presentationBackground(Color.black)
    }
    
    private func formattedMaterialName(_ material: String) -> String {
        let key = "filter_\(material.lowercased().replacingOccurrences(of: " ", with: "_"))"
        let fallback = material.replacingOccurrences(of: "_", with: " ").capitalized
        let localized = NSLocalizedString(key, comment: "")
        
        if localized == key {
            return fallback
        } else {
            return localized
        }
    }
}
