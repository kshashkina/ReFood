import SwiftUI

struct ProductComparisonScreen: View {
    @StateObject private var vm: ProductComparisonViewModel
    let onBack: () -> Void
    
    init(
        productA: Product,
        productB: Product,
        aiRepository: AIComparisonRepository,
        languageProvider: LanguageProvider,
        onBack: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: ProductComparisonViewModel(
            productA: productA,
            productB: productB,
            aiRepository: aiRepository,
            languageProvider: languageProvider
        ))
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ComparisonHeaderCards(vm: vm)
                        .padding(.top, 105)
                    
                    ComparisonGradesSection(vm: vm)
                    
                    ComparisonNutritionSection(vm: vm)
                    
                    ComparisonAISection(vm: vm)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            
            ComparisonTopBar(onBack: onBack)
        }
    }
}
