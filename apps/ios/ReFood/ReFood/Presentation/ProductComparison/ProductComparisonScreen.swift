import SwiftUI

struct ProductComparisonScreen: View {
    @StateObject private var vm: ProductComparisonViewModel
    let analytics: AnalyticsServiceProtocol
    let onBack: () -> Void
    
    init(
        productA: Product,
        productB: Product,
        aiRepository: AIComparisonRepository,
        languageProvider: LanguageProvider,
        analytics: AnalyticsServiceProtocol,
        onBack: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: ProductComparisonViewModel(
            productA: productA,
            productB: productB,
            aiRepository: aiRepository,
            languageProvider: languageProvider
        ))
        self.analytics = analytics
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
                    
                    ComparisonAISection(vm: vm, analytics: analytics)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            
            ComparisonTopBar(onBack: {
                analytics.track(ComparisonEvent.backTap)
                onBack()
            })
        }
        .onAppear {
            analytics.track(ComparisonEvent.screenView)
        }
        .sheet(isPresented: $vm.showNoInternet) {
            NoInternetSheet {
                vm.showNoInternet = false
            }
            .presentationDetents([.height(360)])
        }
    }
}
