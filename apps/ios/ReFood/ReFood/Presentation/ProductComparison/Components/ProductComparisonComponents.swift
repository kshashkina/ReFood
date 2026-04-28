import SwiftUI

struct ComparisonTopBar: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.80))
                .frame(height: 132)
                .overlay(
                    HStack(spacing: 12) {
                        CircleBackButton(action: onBack)
                        
                        Text("comparison_title")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 68)
                    .padding(.bottom, 16)
                )
                .overlay(
                    Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1),
                    alignment: .bottom
                )
        }
        .ignoresSafeArea()
    }
}

struct ComparisonHeaderCards: View {
    @ObservedObject var vm: ProductComparisonViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ComparisonProductCard(
                letter: "A",
                name: vm.displayName(for: vm.productA),
                brand: vm.primaryBrand(for: vm.productA),
                isWinner: vm.isWinner(product: vm.productA)
            )
            
            ComparisonProductCard(
                letter: "B",
                name: vm.displayName(for: vm.productB),
                brand: vm.primaryBrand(for: vm.productB),
                isWinner: vm.isWinner(product: vm.productB)
            )
        }
    }
}

struct ComparisonProductCard: View {
    let letter: String
    let name: String
    let brand: String
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appAccent.opacity(0.2))
                        .frame(width: 64, height: 64)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appAccent, lineWidth: 2))
                        .shadow(color: Color.appAccent.opacity(0.2), radius: 15)
                    
                    Text(letter)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.appAccent)
                }
                
                if isWinner {
                    Text("👑")
                        .font(.system(size: 24))
                        .offset(x: 12, y: -12)
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.top, 16)
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(brand)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
                    .lineLimit(1)
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .background(
            isWinner
            ? LinearGradient(colors: [Color.appAccent.opacity(0.1), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isWinner ? Color.appAccent.opacity(0.5) : Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: isWinner ? Color.appAccent.opacity(0.15) : Color.black.opacity(0.10), radius: 10, y: 8)
        .animation(.spring(), value: isWinner)
    }
}

struct ComparisonGradesSection: View {
    @ObservedObject var vm: ProductComparisonViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("comparison_section_grades")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            gradeRow(title: "NutriScore", valA: vm.formattedGrade(for: vm.productA, path: \.nutriscoreGrade), valB: vm.formattedGrade(for: vm.productB, path: \.nutriscoreGrade))
            gradeRow(title: "EcoScore", valA: vm.formattedGrade(for: vm.productA, path: \.ecoscoreGrade), valB: vm.formattedGrade(for: vm.productB, path: \.ecoscoreGrade))
        }
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
    
    private func gradeRow(title: String, valA: String, valB: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            
            HStack(spacing: 12) {
                gradeBox(grade: valA)
                gradeBox(grade: valB)
            }
        }
    }
    
    private func gradeBox(grade: String) -> some View {
        let color = Color.grade(grade)
        
        return Text(grade)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(color.opacity(0.15))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

struct ComparisonNutritionSection: View {
    @ObservedObject var vm: ProductComparisonViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("comparison_section_nutrition")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                nutrientRow(title: "comparison_nutrient_calories", data: vm.getNutrientData(path: \.energyKcal100g, suffix: "kcal", lowerIsBetter: true))
                nutrientRow(title: "comparison_nutrient_protein", data: vm.getNutrientData(path: \.proteins100g, suffix: "g", lowerIsBetter: false))
                nutrientRow(title: "comparison_nutrient_fat", data: vm.getNutrientData(path: \.fat100g, suffix: "g", lowerIsBetter: true))
                nutrientRow(title: "comparison_nutrient_saturated_fat", data: vm.getNutrientData(path: \.saturatedFat100g, suffix: "g", lowerIsBetter: true))
                nutrientRow(title: "comparison_nutrient_carbs", data: vm.getNutrientData(path: \.carbohydrates100g, suffix: "g", lowerIsBetter: true))
                nutrientRow(title: "comparison_nutrient_sugar", data: vm.getNutrientData(path: \.sugars100g, suffix: "g", lowerIsBetter: true))
                nutrientRow(title: "comparison_nutrient_salt", data: vm.getNutrientData(path: \.salt100g, suffix: "g", lowerIsBetter: true))
            }
        }
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
    
    private func nutrientRow(title: LocalizedStringKey, data: ProductComparisonViewModel.NutrientRowData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            
            HStack(spacing: 12) {
                nutrientBox(text: data.valA, result: data.resA)
                nutrientBox(text: data.valB, result: data.resB)
            }
        }
    }
    
    private func nutrientBox(text: String, result: ProductComparisonViewModel.ComparisonResult) -> some View {
        let isBetter = result == .better
        
        return Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isBetter ? .appAccent : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(isBetter ? Color.appAccent.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isBetter ? Color.appAccent : Color.white.opacity(0.10), lineWidth: isBetter ? 2 : 1)
            )
            .shadow(color: isBetter ? Color.appAccent.opacity(0.2) : .clear, radius: 15)
    }
}

struct ComparisonAISection: View {
    @ObservedObject var vm: ProductComparisonViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(vm.hasAIError ? Color.red.opacity(0.25) : Color.appAccent.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(vm.hasAIError ? Color.red.opacity(0.45) : Color.appAccent.opacity(0.4), lineWidth: 1)
                        )
                    
                    Image(systemName: vm.hasAIError ? "exclamationmark.triangle.fill" : "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(vm.hasAIError ? .white : .appAccent)
                }
                
                Text(vm.hasAIError ? "comparison_ai_error_title" : "comparison_ai_insight")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(vm.hasAIError ? .red : .white)
            }
            
            if vm.isAnalyzing {
                AILoadingIndicator()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if let errorKey = vm.aiError {
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey(errorKey))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.75))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        Task { await vm.fetchAIAnalysis() }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                            
                            Text("comparison_retry_button")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(0.95),
                                    Color(red: 180/255, green: 24/255, blue: 32/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.red.opacity(0.25), radius: 16)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else if vm.aiResult != nil {
                VStack(alignment: .leading, spacing: 16) {
                    Text(vm.aiComparisonText ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    if let differences = vm.aiDifferences, !differences.isEmpty {
                        Divider().background(Color.white.opacity(0.1))
                        
                        Text("comparison_key_differences")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.appAccent)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(differences, id: \.self) { diff in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.appAccent)
                                        .font(.system(size: 14, weight: .bold))
                                    Text(diff)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.7))
                                        .lineSpacing(2)
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("comparison_ai_description")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.8))
                        .lineSpacing(4)
                    
                    Button(action: {
                        Task { await vm.fetchAIAnalysis() }
                    }) {
                        Text("comparison_generate_analysis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.appAccent)
                            .cornerRadius(14)
                            .shadow(color: Color.appAccent.opacity(0.3), radius: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(21)
        .background(
            LinearGradient(
                colors: vm.hasAIError
                ? [Color.red.opacity(0.18), Color(red: 70/255, green: 18/255, blue: 18/255).opacity(0.22)]
                : [Color.appAccent.opacity(0.2), Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(vm.hasAIError ? Color.red.opacity(0.45) : Color.appAccent.opacity(0.3), lineWidth: 1)
        )
        .animation(.spring(), value: vm.isAnalyzing)
        .animation(.spring(), value: vm.aiError)
        .animation(.spring(), value: vm.aiResult)
    }
}

struct AILoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.2 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.3)
                        .shadow(color: Color.appAccent, radius: isAnimating ? 10 : 0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                            value: isAnimating
                        )
                }
            }
            
            Text("comparison_ai_loading")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appAccent)
                .opacity(isAnimating ? 1.0 : 0.4)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
