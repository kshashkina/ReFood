import SwiftUI

struct RecyclingScreen: View {
    @StateObject private var vm: RecyclingViewModel
    let analytics: AnalyticsServiceProtocol
    let onBack: () -> Void
    let onFindPointTapped: (String) -> Void
    
    init(
        product: Product,
        languageProvider: LanguageProvider,
        metricsRepository: MetricsRepository,
        analytics: AnalyticsServiceProtocol,
        onBack: @escaping () -> Void,
        onFindPointTapped: @escaping (String) -> Void
    ) {
        self._vm = StateObject(wrappedValue: RecyclingViewModel(
            product: product,
            languageProvider: languageProvider,
            metricsRepository: metricsRepository
        ))
        self.analytics = analytics
        self.onBack = onBack
        self.onFindPointTapped = onFindPointTapped
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    RecyclingProductHeader(
                        name: vm.productName,
                        brand: vm.primaryBrand
                    )
                    
                    if vm.hasPackagingData {
                        ForEach(vm.components) { component in
                            RecyclingComponentCard(component: component)
                        }
                    } else {
                        RecyclingEmptyStateView()
                    }
                    let isButtonDisabled = !vm.hasPackagingData
                    
                    RecyclingFindPointButton(isDisabled: isButtonDisabled) {
                        let filterQuery = vm.combinedMaterialsFilter                        
                        analytics.track(RecyclingEvent.findTap(type: filterQuery))
                        onFindPointTapped(filterQuery)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 105)
                .padding(.bottom, 40)
            }
            
            RecyclingTopBar(onBack: {
                analytics.track(RecyclingEvent.backTap)
                onBack()
            })
        }
        .onAppear {
            analytics.track(RecyclingEvent.screenView)
        }
    }
}
