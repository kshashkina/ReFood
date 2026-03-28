import SwiftUI

struct ProductComparisonScreen: View {
    @StateObject private var vm: ProductComparisonViewModel
    let onBack: () -> Void
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    init(productA: Product, productB: Product, onBack: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: ProductComparisonViewModel(productA: productA, productB: productB))
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCards
                        .padding(.top, 105)
                    gradesSection
                    nutritionSection
                    aiAnalysisSection
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            topBar
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.80))
                .frame(height: 132)
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
                        
                        Text("Product Comparison")
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
    
    private var headerCards: some View {
        HStack(spacing: 16) {
            productCard(product: vm.productA, letter: "A")
            productCard(product: vm.productB, letter: "B")
        }
    }
    
    private func productCard(product: Product, letter: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(accent.opacity(0.2))
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accent, lineWidth: 2)
                    )
                    .shadow(color: accent.opacity(0.2), radius: 15)
                
                Text(letter)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(accent)
            }
            .padding(.top, 16)
            
            VStack(spacing: 4) {
                Text(product.productName ?? "Unknown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(product.brands?.components(separatedBy: ",").first ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
                    .lineLimit(1)
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 8)
    }
    
    private var gradesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quality Grades")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            gradeRow(title: "NutriScore", path: \.nutriscoreGrade)
            gradeRow(title: "EcoScore", path: \.ecoscoreGrade)
        }
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
    
    private func gradeRow(title: String, path: KeyPath<Product, String?>) -> some View {
        let (resA, resB) = vm.compareGrades(path: path)
        let gradeA = vm.productA[keyPath: path]?.uppercased() ?? "-"
        let gradeB = vm.productB[keyPath: path]?.uppercased() ?? "-"
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            
            HStack(spacing: 12) {
                gradeBox(grade: gradeA, result: resA)
                gradeBox(grade: gradeB, result: resB)
            }
        }
    }
    
    private func gradeBox(grade: String, result: ProductComparisonViewModel.ComparisonResult) -> some View {
        let isBetter = result == .better
        let bgColor = isBetter ? accent.opacity(0.2) : (grade != "-" ? Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.13) : Color.white.opacity(0.05))
        let textColor = isBetter ? accent : (grade != "-" ? Color(red: 245/255, green: 158/255, blue: 11/255) : .gray)
        let strokeColor = isBetter ? accent.opacity(0.3) : (grade != "-" ? Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.19) : Color.white.opacity(0.1))
        
        return Text(grade)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(bgColor)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(strokeColor, lineWidth: 1))
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Facts (per 100g)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                nutrientRow(title: "Calories", path: \.energyKcal100g, suffix: "kcal", lowerIsBetter: true)
                nutrientRow(title: "Protein", path: \.proteins100g, suffix: "g", lowerIsBetter: false)
                nutrientRow(title: "Fat", path: \.fat100g, suffix: "g", lowerIsBetter: true)
                nutrientRow(title: "Saturated fat", path: \.saturatedFat100g, suffix: "g", lowerIsBetter: true)
                nutrientRow(title: "Carbohydrates", path: \.carbohydrates100g, suffix: "g", lowerIsBetter: true)
                nutrientRow(title: "Sugar", path: \.sugars100g, suffix: "g", lowerIsBetter: true)
                nutrientRow(title: "Salt", path: \.salt100g, suffix: "g", lowerIsBetter: true)
            }
        }
        .padding(21)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
    
    private func nutrientRow(title: String, path: KeyPath<Nutriments, Double?>, suffix: String, lowerIsBetter: Bool) -> some View {
        let (resA, resB) = vm.compareNutrient(path: path, lowerIsBetter: lowerIsBetter)
        
        let valA = vm.productA.nutriments?[keyPath: path]
        let valB = vm.productB.nutriments?[keyPath: path]
        
        let strA = valA != nil ? String(format: "%.1f %@", valA!, suffix) : "-"
        let strB = valB != nil ? String(format: "%.1f %@", valB!, suffix) : "-"
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            
            HStack(spacing: 12) {
                nutrientBox(text: strA, result: resA)
                nutrientBox(text: strB, result: resB)
            }
        }
    }
    
    private func nutrientBox(text: String, result: ProductComparisonViewModel.ComparisonResult) -> some View {
        let isBetter = result == .better
        
        return Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isBetter ? accent : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(isBetter ? accent.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isBetter ? accent : Color.white.opacity(0.10), lineWidth: isBetter ? 2 : 1)
            )
            .shadow(color: isBetter ? accent.opacity(0.2) : .clear, radius: 15)
    }
    
    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accent.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(accent.opacity(0.4), lineWidth: 1))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(accent)
                }
                
                Text("AI Insight")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Get detailed AI comparison analysis and personalized recommendations")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.8))
                .lineSpacing(4)
            
            Button(action: {}) {
                Text("Generate analysis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(accent)
                    .cornerRadius(14)
                    .shadow(color: accent.opacity(0.3), radius: 20)
            }
            .buttonStyle(.plain)
        }
        .padding(21)
        .background(
            LinearGradient(
                colors: [accent.opacity(0.2), Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.25), radius: 50, y: 25)
    }
}
