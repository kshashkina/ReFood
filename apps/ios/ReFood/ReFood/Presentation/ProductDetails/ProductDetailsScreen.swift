import SwiftUI

struct ProductDetailsScreen: View {
    @StateObject private var vm: ProductDetailsViewModel
    
    private let repository: ProductRepository
    private let uploadService: ImageUploadServicing
    private let languageProvider: LanguageProvider
    
    let onBack: () -> Void
    var onCompare: (Product) -> Void
    
    @State private var showRecycling = false
    @State private var showEditScreen = false

    enum NutritionTab: String, CaseIterable {
        case per100g = "details_tab_100g"
        case perServing = "details_tab_serving"
    }

    init(
        product: Product,
        repository: ProductRepository,
        uploadService: ImageUploadServicing,
        languageProvider: LanguageProvider,
        onBack: @escaping () -> Void,
        onCompare: @escaping (Product) -> Void = { _ in }
    ) {
        self._vm = StateObject(wrappedValue: ProductDetailsViewModel(product: product, languageProvider: languageProvider))
        self.repository = repository
        self.uploadService = uploadService
        self.languageProvider = languageProvider
        self.onBack = onBack
        self.onCompare = onCompare
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    DetailsHeroImage(imageUrl: vm.product.imageUrl)
                        .padding(.top, 100)
                        .padding(.horizontal, 24)
                    
                    DetailsInfoCard(vm: vm)
                        .padding(.horizontal, 24)
                    
                    if let insight = vm.aiAnalysis {
                        AIInsightCard(text: insight)
                            .padding(.horizontal, 24)
                    }

                    DetailsScoreRow(vm: vm)
                        .padding(.horizontal, 24)
                    
                    DetailsIngredientsCard(vm: vm)
                        .padding(.horizontal, 24)
                    
                    DetailsNutritionCard(vm: vm)
                        .padding(.horizontal, 24)
                    
                    DetailsPackagingCard(vm: vm, onSortTapped: { showRecycling = true })
                        .padding(.horizontal, 24)
                    
                    DetailsCompareButton(onCompare: { onCompare(vm.product) })
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
            
            DetailsTopBar(
                onBack: onBack,
                onEdit: { showEditScreen = true }
            )
        }
        .fullScreenCover(isPresented: $showRecycling) {
            RecyclingScreen(
                product: vm.product,
                languageProvider: languageProvider,
                onBack: { showRecycling = false },
                onFindPointTapped: {}
            )
        }
        .fullScreenCover(isPresented: $showEditScreen) {
            AddProductScreen(
                barcode: vm.product.barcode,
                existingProduct: vm.product,
                repository: repository,
                uploadService: uploadService
            )
        }
    }
}
