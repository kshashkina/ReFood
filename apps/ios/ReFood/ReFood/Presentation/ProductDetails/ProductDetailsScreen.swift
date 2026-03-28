import SwiftUI

struct ProductDetailsScreen: View {

    let product: Product
    let onBack: () -> Void
    var onCompare: (Product) -> Void = { _ in }

    let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    enum NutritionTab: String, CaseIterable {
        case per100g = "Per 100g"
        case perServing = "Per serving"
    }

    @State private var tab: NutritionTab = .per100g

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    heroImage
                        .padding(.top, 100)
                        .padding(.horizontal, 24)

                    infoCard
                        .padding(.horizontal, 24)
                    
                    if let insight = aiAnalysis {
                        AIInsightCard(text: insight)
                            .padding(.horizontal, 24)
                    }

                    scoreRow
                        .padding(.horizontal, 24)

                    ingredientsCard
                        .padding(.horizontal, 24)

                    nutritionCard
                        .padding(.horizontal, 24)

                    packagingCard
                        .padding(.horizontal, 24)

                    compareButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
            topBar
        }
    }


    private var topBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.60))
                .frame(height: 132)
                .overlay(
                    HStack {
                        iconButton("chevron.left", action: onBack)

                        Spacer()

                        HStack(spacing: 8) {
                            iconButton("heart") { }
                            iconButton("square.and.arrow.up") { }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 68)
                    .padding(.bottom, 12)
                )
                .overlay(
                    Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1),
                    alignment: .bottom
                )

            Spacer()
        }
        .ignoresSafeArea()
    }

    private func iconButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white.opacity(0.20), lineWidth: 1))
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
    }

    private var heroImage: some View {
        GlassCard(cornerRadius: 24, padding: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 45/255, green: 69/255, blue: 48/255),
                                Color(red: 90/255, green: 110/255, blue: 75/255)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: accent.opacity(0.20), radius: 20)

                CachedAsyncImage(
                    url: URL(string: product.imageUrl ?? ""),
                    contentMode: .fill
                ) {
                    placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .frame(height: 194)
        }
        .frame(height: 194)
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 34, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.25))
    }


    private var infoCard: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .bold))

                    if let brand = brand {
                        Text(brand)
                            .foregroundStyle(Color.white.opacity(0.60))
                            .font(.system(size: 16))
                    }

                    if let cats = categoriesLine {
                        Text(cats)
                            .foregroundStyle(Color.white.opacity(0.50))
                            .font(.system(size: 14))
                            .lineLimit(2)
                    }
                }

                Text("Barcode: \(product.barcode)")
                    .foregroundStyle(Color.white.opacity(0.40))
                    .font(.system(size: 12))
            }
        }
    }


    private var scoreRow: some View {
        HStack(spacing: 12) {
            ScoreCard(
                title: "NutriScore",
                grade: (product.nutriscoreGrade ?? "-").uppercased(),
                subtitle: ProductDetailsFormatter.nutriSubtitle(for: product.nutriscoreGrade),
                tint: ProductDetailsFormatter.gradeColor(product.nutriscoreGrade)
            )

            ScoreCard(
                title: "EcoScore",
                grade: (product.ecoscoreGrade ?? "-").uppercased(),
                subtitle: ProductDetailsFormatter.ecoSubtitle(for: product.ecoscoreGrade),
                tint: ProductDetailsFormatter.gradeColor(product.ecoscoreGrade)
            )
        }
    }

    private var ingredientsCard: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ingredients")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))

                if ingredientsList.isEmpty {
                    Text("No ingredients data")
                        .foregroundStyle(Color.white.opacity(0.55))
                        .font(.system(size: 14))
                } else {
                    ForEach(ingredientsList, id: \.self) { item in
                        BulletRow(text: item, accent: accent)
                    }
                }

                DividerLine()

                Text("Allergens")
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .semibold))

                if allergensList.isEmpty {
                    Text("No allergens listed")
                        .foregroundStyle(Color.white.opacity(0.55))
                        .font(.system(size: 14))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allergensList, id: \.self) { a in
                                Chip(text: a, tint: .orange)
                            }
                        }
                    }
                }
            }
        }
    }

    private var nutritionCard: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Nutrition facts")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))

                NutritionToggle(selection: $tab, accent: accent)

                VStack(spacing: 12) {
                    NutritionRow(
                        label: "Calories",
                        value: ProductDetailsFormatter.caloriesString(product: product, tab: tab)
                    )
                    NutritionRow(
                        label: "Protein",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.proteins(product: product, tab: tab))
                    )
                    NutritionRow(
                        label: "Fat",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.fat(product: product, tab: tab))
                    )
                    NutritionRow(
                        label: "Saturated fat",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.saturatedFat(product: product, tab: tab))
                    )
                    NutritionRow(
                        label: "Carbohydrates",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.carbs(product: product, tab: tab))
                    )
                    NutritionRow(
                        label: "Sugar",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.sugars(product: product, tab: tab))
                    )
                    NutritionRow(
                        label: "Salt",
                        value: ProductDetailsFormatter.gramsString(ProductDetailsFormatter.salt(product: product, tab: tab))
                    )
                }
            }
        }
    }

    private var packagingCard: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Packaging")
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Button { } label: {
                        Text("How to sort")
                            .foregroundStyle(.black)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(accent)
                            .clipShape(Capsule())
                            .shadow(color: accent.opacity(0.30), radius: 10)
                    }
                    .buttonStyle(.plain)
                }

                let items = packagingItems
                if items.isEmpty {
                    Text("No packaging data")
                        .foregroundStyle(Color.white.opacity(0.55))
                        .font(.system(size: 14))
                } else {
                    VStack(spacing: 12) {
                        ForEach(0..<items.count, id: \.self) { index in
                            let item = items[index]
                            PackagingRow(
                                title: item.title,
                                subtitle: item.subtitle,
                                accent: accent
                            )
                        }
                    }
                }
            }
        }
    }

    private var compareButton: some View {
        Button {onCompare(product)} label: {
            HStack(spacing: 12) {
                Image(systemName: "square.split.2x1")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Compare with another product")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Color.white.opacity(0.05))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }


    private var displayName: String { ProductDetailsMapper.displayName(for: product) }
    private var brand: String? { ProductDetailsMapper.brand(for: product) }
    private var categoriesLine: String? { ProductDetailsMapper.categoriesLine(for: product) }
    private var ingredientsList: [String] { ProductDetailsMapper.ingredientsList(for: product) }
    private var allergensList: [String] { ProductDetailsMapper.allergensList(for: product) }
    private var packagingItems: [(title: String, subtitle: String)] { ProductDetailsMapper.packagingItems(for: product) }
    private var aiAnalysis: String? { ProductDetailsMapper.aiAnalysis(for: product) }
}
