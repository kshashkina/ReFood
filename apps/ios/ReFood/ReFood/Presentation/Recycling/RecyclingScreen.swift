import SwiftUI

struct RecyclingScreen: View {
    @StateObject private var vm: RecyclingViewModel
    let onBack: () -> Void
    let onFindPointTapped: () -> Void
    
    init(
        product: Product,
        languageProvider: LanguageProvider,
        onBack: @escaping () -> Void,
        onFindPointTapped: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: RecyclingViewModel(
            product: product,
            languageProvider: languageProvider
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
                    
                    RecyclingWasteTypesSection(wasteTypes: vm.standardWasteTypes)
                    
                    Button(action: onFindPointTapped) {
                        Text("recycling_find_point_button")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appAccent)
                            .cornerRadius(16)
                            .shadow(color: Color.appAccent.opacity(0.4), radius: 15, y: 5)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 105)
                .padding(.bottom, 40)
            }
            
            RecyclingTopBar(onBack: onBack)
        }
    }
}
