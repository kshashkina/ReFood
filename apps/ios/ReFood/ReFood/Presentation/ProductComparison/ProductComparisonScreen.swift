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
        let isWinner = vm.aiResult?.winnerBarcode == product.barcode
        
        return VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
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
        .background(
            isWinner ? LinearGradient(colors: [accent.opacity(0.1), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isWinner ? accent.opacity(0.5) : Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: isWinner ? accent.opacity(0.15) : Color.black.opacity(0.10), radius: 10, y: 8)
        .animation(.spring(), value: isWinner)
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
        let gradeA = vm.productA[keyPath: path]?.uppercased() ?? "-"
        let gradeB = vm.productB[keyPath: path]?.uppercased() ?? "-"
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 123/255, green: 123/255, blue: 123/255))
            
            HStack(spacing: 12) {
                gradeBox(grade: gradeA)
                gradeBox(grade: gradeB)
            }
        }
    }
    
    private func gradeBox(grade: String) -> some View {
        let color = gradeColor(grade)
        
        return Text(grade)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(color.opacity(0.15))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func gradeColor(_ grade: String?) -> Color {
        switch (grade ?? "").lowercased() {
        case "a": return Color(red: 144/255, green: 240/255, blue: 71/255)
        case "b": return Color(red: 179/255, green: 243/255, blue: 87/255)
        case "c": return Color(red: 245/255, green: 221/255, blue: 77/255)
        case "d": return Color(red: 255/255, green: 163/255, blue: 62/255)
        case "e": return Color(red: 255/255, green: 84/255,  blue: 84/255)
        case "f": return Color(red: 255/255, green: 50/255,  blue: 50/255)
        default:  return Color.white.opacity(0.45)
        }
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
            
            if vm.isAnalyzing {
                HStack {
                    Spacer()
                    AILoadingIndicator()
                        .padding(.vertical, 32)
                    Spacer()
                }
            } else if let result = vm.aiResult {
                VStack(alignment: .leading, spacing: 16) {
                    Text(result.comparisonEn ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    if let differences = result.keyDifferencesEn, !differences.isEmpty {
                        Divider().background(Color.white.opacity(0.1))
                        
                        Text("Key Differences")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accent)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(differences, id: \.self) { diff in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(accent)
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
                    Text("Get detailed AI comparison analysis and personalized recommendations")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.8))
                        .lineSpacing(4)
                    
                    Button(action: {
                        Task { await vm.fetchAIAnalysis() }
                    }) {
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
            }
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.isAnalyzing)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.aiResult)
    }
}

struct AILoadingIndicator: View {
    @State private var isAnimating = false
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(accent)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.2 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.3)
                        .shadow(color: accent, radius: isAnimating ? 10 : 0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                            value: isAnimating
                        )
                }
            }
            
            Text("AI is analyzing data...")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(accent)
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
