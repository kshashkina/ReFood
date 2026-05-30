import SwiftUI

struct DetailsTopBar: View {
    let onBack: () -> Void
    let onLike: () -> Void
    let onShare: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.60))
                .frame(height: 132)
                .overlay(
                    HStack {
                        iconButton("chevron.left", action: onBack)
                        Spacer()
                        HStack(spacing: 8) {
                            iconButton("heart", action: onLike)
                            iconButton("square.and.arrow.up", action: onShare)
                            iconButton("pencil", action: onEdit)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 68)
                    .padding(.bottom, 12)
                )
                .overlay(Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1), alignment: .bottom)
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func iconButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle().fill(Color.white.opacity(0.10)).frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white.opacity(0.20), lineWidth: 1))
                .overlay(Image(systemName: systemName).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
        }
        .buttonStyle(.plain)
    }
}

struct DetailsHeroImage: View {
    let imageUrl: String?
    
    var body: some View {
        GlassCard(cornerRadius: 24, padding: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [Color(red: 45/255, green: 69/255, blue: 48/255), Color(red: 90/255, green: 110/255, blue: 75/255)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Color.appAccent.opacity(0.20), radius: 20)

                CachedAsyncImage(url: URL(string: imageUrl ?? ""), contentMode: .fill) {
                    Image(systemName: "photo").font(.system(size: 34, weight: .semibold)).foregroundStyle(Color.white.opacity(0.25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).clipped().clipShape(RoundedRectangle(cornerRadius: 24))
            }.frame(height: 194)
        }.frame(height: 194)
    }
}

struct DetailsInfoCard: View {
    @ObservedObject var vm: ProductDetailsViewModel
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.displayName).foregroundStyle(.white).font(.system(size: 24, weight: .bold))
                    if let brand = vm.brand { Text(brand).foregroundStyle(Color.white.opacity(0.60)).font(.system(size: 16)) }
                    if let cats = vm.categoriesLine { Text(cats).foregroundStyle(Color.white.opacity(0.50)).font(.system(size: 14)).lineLimit(2) }
                }
                Text("details_barcode \(vm.product.barcode)").foregroundStyle(Color.white.opacity(0.40)).font(.system(size: 12))
            }
        }
    }
}

struct DetailsScoreRow: View {
    @ObservedObject var vm: ProductDetailsViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ScoreCard(
                title: "NutriScore",
                grade: vm.nutriScoreGrade,
                subtitleKey: vm.nutriSubtitleKey,
                tint: Color.grade(vm.product.nutriscoreGrade ?? "")
            )
            ScoreCard(
                title: "EcoScore",
                grade: vm.ecoScoreGrade,
                subtitleKey: vm.ecoSubtitleKey,
                tint: Color.grade(vm.product.ecoscoreGrade ?? "")
            )
        }
    }
}

struct DetailsIngredientsCard: View {
    @ObservedObject var vm: ProductDetailsViewModel
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 12) {
                Text("details_ingredients_title").foregroundStyle(.white).font(.system(size: 18, weight: .semibold))
                
                if vm.ingredientsList.isEmpty {
                    Text("details_ingredients_empty").foregroundStyle(Color.white.opacity(0.55)).font(.system(size: 14))
                } else {
                    ForEach(vm.ingredientsList, id: \.self) { item in
                        BulletRow(text: item)
                    }
                }
                DividerLine()
                Text("details_allergens_title").foregroundStyle(.white).font(.system(size: 14, weight: .semibold))
                
                if vm.allergensList.isEmpty {
                    Text("details_allergens_empty").foregroundStyle(Color.white.opacity(0.55)).font(.system(size: 14))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.allergensList, id: \.self) { a in Chip(text: a, tint: .orange) }
                        }
                    }
                }
            }
        }
    }
}

struct DetailsNutritionCard: View {
    @ObservedObject var vm: ProductDetailsViewModel
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 16) {
                Text("details_nutrition_title").foregroundStyle(.white).font(.system(size: 18, weight: .semibold))
                NutritionToggle(selection: $vm.nutritionTab)

                VStack(spacing: 12) {
                    NutritionRow(labelKey: "details_nutri_calories", value: vm.caloriesString())
                    NutritionRow(labelKey: "details_nutri_protein", value: vm.gramsString(for: \.proteins100g, serving: \.proteinsServing))
                    NutritionRow(labelKey: "details_nutri_fat", value: vm.gramsString(for: \.fat100g, serving: \.fatServing))
                    NutritionRow(labelKey: "details_nutri_sat_fat", value: vm.gramsString(for: \.saturatedFat100g, serving: \.saturatedFatServing))
                    NutritionRow(labelKey: "details_nutri_carbs", value: vm.gramsString(for: \.carbohydrates100g, serving: \.carbohydratesServing))
                    NutritionRow(labelKey: "details_nutri_sugar", value: vm.gramsString(for: \.sugars100g, serving: \.sugarsServing))
                    NutritionRow(labelKey: "details_nutri_salt", value: vm.gramsString(for: \.salt100g, serving: \.saltServing))
                }
            }
        }
    }
}

struct DetailsPackagingCard: View {
    @ObservedObject var vm: ProductDetailsViewModel
    let onSortTapped: () -> Void
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 21) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("details_packaging_title").foregroundStyle(.white).font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: onSortTapped) {
                        Text("details_packaging_sort_btn")
                            .foregroundStyle(.black).font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 13).padding(.vertical, 7).background(Color.appAccent)
                            .clipShape(Capsule()).shadow(color: Color.appAccent.opacity(0.30), radius: 10)
                    }.buttonStyle(.plain)
                }

                if vm.packagingItems.isEmpty {
                    Text("details_packaging_empty").foregroundStyle(Color.white.opacity(0.55)).font(.system(size: 14))
                } else {
                    VStack(spacing: 12) {
                        ForEach(0..<vm.packagingItems.count, id: \.self) { index in
                            let item = vm.packagingItems[index]
                            PackagingRow(title: item.title, subtitle: item.subtitle)
                        }
                    }
                }
            }
        }
    }
}

struct DetailsCompareButton: View {
    let onCompare: () -> Void
    
    var body: some View {
        Button(action: onCompare) {
            HStack(spacing: 12) {
                Image(systemName: "square.split.2x1").font(.system(size: 18, weight: .semibold)).foregroundStyle(.white)
                Text("details_compare_btn").foregroundStyle(.white).font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20).frame(height: 58).background(Color.white.opacity(0.05))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10))).clipShape(RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain)
    }
}


struct AIInsightCard: View {
    let text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(stops: [.init(color: Color.appAccent.opacity(0.15), location: 0), .init(color: Color(red: 90/255, green: 110/255, blue: 75/255).opacity(0.15), location: 1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Circle().fill(Color.appAccent.opacity(0.15)).frame(width: 150, height: 150).blur(radius: 45).offset(x: 120, y: -50), alignment: .topTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appAccent.opacity(0.25), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color.appAccent.opacity(0.25)).frame(width: 32, height: 32)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appAccent.opacity(0.4), lineWidth: 1))
                        Image(systemName: "sparkles").font(.system(size: 14, weight: .bold)).foregroundStyle(Color.appAccent)
                    }
                    Text("details_ai_analysis_title").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                }
                Text(text).font(.system(size: 14, weight: .regular)).lineSpacing(5).foregroundStyle(.white.opacity(0.9)).fixedSize(horizontal: false, vertical: true)
            }.padding(20)
        }
    }
}

struct BulletRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(Color.appAccent).frame(width: 6, height: 6).shadow(color: Color.appAccent.opacity(0.60), radius: 6)
            Text(text).foregroundStyle(Color.white.opacity(0.90)).font(.system(size: 14))
            Spacer()
        }
    }
}

struct Chip: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text).foregroundStyle(tint).font(.system(size: 12, weight: .medium)).padding(.horizontal, 13).padding(.vertical, 6)
            .background(tint.opacity(0.20)).overlay(Capsule().stroke(tint.opacity(0.30))).clipShape(Capsule())
    }
}

struct DividerLine: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1).padding(.vertical, 6)
    }
}

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content.padding(padding).frame(maxWidth: .infinity, alignment: .leading).background(Color.white.opacity(0.05))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.white.opacity(0.10)))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius)).shadow(color: Color.black.opacity(0.10), radius: 12, y: 6)
    }
}

struct NutritionRow: View {
    let labelKey: String
    let value: String

    var body: some View {
        HStack {
            Text(LocalizedStringKey(labelKey)).foregroundStyle(Color.white.opacity(0.60)).font(.system(size: 14))
            Spacer()
            Text(value).foregroundStyle(.white).font(.system(size: 14, weight: .semibold))
        }
    }
}

struct NutritionToggle: View {
    @Binding var selection: ProductDetailsScreen.NutritionTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ProductDetailsScreen.NutritionTab.allCases, id: \.self) { mode in
                Button { selection = mode } label: {
                    Text(LocalizedStringKey(mode.rawValue))
                        .foregroundStyle(selection == mode ? Color.black : Color.white.opacity(0.60))
                        .font(.system(size: 14, weight: .medium)).frame(maxWidth: .infinity).frame(height: 38)
                        .background(selection == mode ? Color.appAccent : Color.white.opacity(0.05))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(selection == mode ? 0 : 0.10)))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)
            }
        }
    }
}

struct PackagingRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundStyle(.white).font(.system(size: 14, weight: .medium))
                if !subtitle.isEmpty { Text(subtitle).foregroundStyle(Color.white.opacity(0.60)).font(.system(size: 12)) }
            }
            Spacer()
            Circle().fill(Color.appAccent).frame(width: 8, height: 8)
        }
        .padding(.horizontal, 12).frame(height: 64).background(Color.white.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10))).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ScoreCard: View {
    let title: String
    let grade: String
    let subtitleKey: String
    let tint: Color

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 17) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).foregroundStyle(Color.white.opacity(0.60)).font(.system(size: 12))
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.16)).overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.28))).frame(width: 46, height: 48)
                        Text(grade).foregroundStyle(tint).font(.system(size: 24, weight: .bold))
                    }
                    Text(LocalizedStringKey(subtitleKey)).foregroundStyle(.white).font(.system(size: 14, weight: .medium))
                    Spacer(minLength: 0)
                }
            }
        }
    }
}
