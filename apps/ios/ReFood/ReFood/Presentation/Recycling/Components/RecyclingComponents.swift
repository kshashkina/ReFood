import SwiftUI

struct RecyclingTopBar: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.80))
                .frame(height: 120)
                .overlay(
                    HStack(spacing: 12) {
                        CircleBackButton(action: onBack)
                        
                        Text("recycling_title")
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
}

struct RecyclingProductHeader: View {
    let name: String
    let brand: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(brand)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .recyclingCardStyle()
    }
}

struct RecyclingWasteTypesSection: View {
    let wasteTypes: [RecyclingViewModel.WasteType]
    let selectedType: RecyclingViewModel.WasteType?
    let onSelect: (RecyclingViewModel.WasteType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("recycling_waste_types")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("recycling_select_type_prompt")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                ForEach(wasteTypes) { type in
                    RecyclingWasteTypeRow(
                        emoji: type.emoji,
                        titleKey: type.titleKey,
                        isSelected: selectedType?.id == type.id
                    )
                    .onTapGesture { onSelect(type) }
                }
            }
        }
        .recyclingCardStyle()
    }
}

struct RecyclingWasteTypeRow: View {
    let emoji: String
    let titleKey: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appAccent.opacity(0.10))
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appAccent.opacity(0.20), lineWidth: 1))
                Text(emoji).font(.system(size: 20))
            }
            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appAccent)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 66)
        .background(isSelected ? Color.appAccent.opacity(0.15) : Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.appAccent : Color.white.opacity(0.10), lineWidth: 1))
    }
}

struct RecyclingEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.system(size: 40))
                .foregroundColor(Color.appAccent.opacity(0.5))
            Text("recycling_empty_state")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .recyclingCardStyle()
    }
}

struct RecyclingComponentCard: View {
    let component: RecyclingViewModel.ComponentViewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(component.shapeTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(component.materialTitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            }
            
            Text(component.categoryTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appAccent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.appAccent.opacity(0.20))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appAccent.opacity(0.30), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("recycling_how_to_prepare")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                ForEach(Array(component.preparationSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.appAccent)
                            .frame(width: 20, height: 20)
                            .background(Color.appAccent.opacity(0.20))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.appAccent.opacity(0.30), lineWidth: 1))
                            .padding(.top, 2)
                        
                        Text(step)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .recyclingCardStyle()
    }
}

struct RecyclingFindPointButton: View {
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("recycling_find_point_button")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDisabled ? .white.opacity(0.4) : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDisabled ? Color.white.opacity(0.1) : Color.appAccent)
                .cornerRadius(16)
                .shadow(color: isDisabled ? .clear : Color.appAccent.opacity(0.4), radius: 15, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .padding(.top, 8)
    }
}

struct RecyclingCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(21)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 10, y: 8)
    }
}

extension View {
    func recyclingCardStyle() -> some View {
        self.modifier(RecyclingCardStyle())
    }
}
