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
                    
                    RecyclingWasteTypesSection(
                        wasteTypes: vm.standardWasteTypes,
                        selectedType: vm.selectedWasteType,
                        onSelect: {
                            analytics.track(RecyclingEvent.selectTap(type: $0.titleKey))
                            vm.selectedWasteType = $0
                        }
                    )
                    
                    let isButtonDisabled = vm.selectedWasteType == nil
                    
                    RecyclingFindPointButton(isDisabled: isButtonDisabled) {
                        guard let selected = vm.selectedWasteType else { return }
                        analytics.track(RecyclingEvent.findTap(type: selected.titleKey))
                        onFindPointTapped(selected.filterKey)
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
