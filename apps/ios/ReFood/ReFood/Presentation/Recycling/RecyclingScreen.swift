import SwiftUI

struct RecyclingScreen: View {
    @StateObject private var vm: RecyclingViewModel
    let onBack: () -> Void
    let onFindPointTapped: (String) -> Void
    init(
        product: Product,
        languageProvider: LanguageProvider,
        metricsRepository: MetricsRepositoryProtocol,
        onBack: @escaping () -> Void,
        onFindPointTapped: @escaping (String) -> Void
    ) {
        self._vm = StateObject(wrappedValue: RecyclingViewModel(
            product: product,
            languageProvider: languageProvider,
            metricsRepository: metricsRepository
        ))
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
                        onSelect: { vm.selectedWasteType = $0 }
                    )
                    
                    let isButtonDisabled = vm.selectedWasteType == nil
                    
                    RecyclingFindPointButton(isDisabled: isButtonDisabled) {
                        guard let selected = vm.selectedWasteType else { return }
                        vm.incrementSortedCount()
                        onFindPointTapped(selected.filterKey)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 105)
                .padding(.bottom, 40)
            }
            
            RecyclingTopBar(onBack: onBack)
        }
    }
}
