import SwiftUI

struct RecyclingScreen: View {
    let product: Product
    let onBack: () -> Void
    
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    productHeader
                    
                    if let packaging = product.packagingEn, !packaging.isEmpty {
                        ForEach(Array(packaging.enumerated()), id: \.offset) { _, item in
                            let category = RecyclingCategory.from(material: item.material)
                            RecyclingComponentCard(item: item, category: category)
                        }
                    } else {
                        emptyStateView
                    }
                    
                    wasteTypesSection
                    
                    Button {
                        print("Find recycling point tapped")
                    } label: {
                        Text("Find recycling point")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(accent)
                            .cornerRadius(16)
                            .shadow(color: accent.opacity(0.4), radius: 15, y: 5)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 105)
                .padding(.bottom, 40)
            }
            
            topBar
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.80))
                .frame(height: 120)
                .overlay(
                    HStack(spacing: 12) {
                        Button(action: onBack) {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
                                .overlay(
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Recycling Instructions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                )
                .overlay(Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1), alignment: .bottom)
        }
        .ignoresSafeArea()
    }
    
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.productName ?? "Unknown Product")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(product.brands?.components(separatedBy: ",").first ?? "")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 8)
    }
    
    private var wasteTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Waste Types")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                wasteTypeRow(emoji: "📄", title: "Paper & Cardboard")
                wasteTypeRow(emoji: "♻️", title: "Plastic")
                wasteTypeRow(emoji: "🫙", title: "Glass")
                wasteTypeRow(emoji: "🔩", title: "Metal")
                wasteTypeRow(emoji: "🌱", title: "Organic")
                wasteTypeRow(emoji: "🗑️", title: "Mixed Waste")
            }
        }
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 8)
    }
    
    private func wasteTypeRow(emoji: String, title: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(accent.opacity(0.10))
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.20), lineWidth: 1))
                Text(emoji).font(.system(size: 20))
            }
            Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 66)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.system(size: 40))
                .foregroundColor(accent.opacity(0.5))
            Text("No packaging data available")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}

struct RecyclingComponentCard: View {
    let item: PackagingItem
    let category: RecyclingCategory
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.shape?.capitalized ?? "Packaging Element")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(item.material?.capitalized ?? "Unknown Material")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            }
            
            Text(category.titleEn)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(accent.opacity(0.20))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(accent.opacity(0.30), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How to prepare:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                ForEach(Array(category.prepStepsEn.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(accent)
                            .frame(width: 20, height: 20)
                            .background(accent.opacity(0.20))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(accent.opacity(0.30), lineWidth: 1))
                            .padding(.top, 2)
                        
                        Text(step)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(21)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 8)
    }
}
