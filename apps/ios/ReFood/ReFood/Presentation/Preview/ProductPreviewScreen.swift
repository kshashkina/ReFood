import SwiftUI

struct ProductPreviewScreen: View {
    @StateObject private var vm: ProductPreviewViewModel
    
    let analytics: AnalyticsServiceProtocol
    let onBack: () -> Void
    let onContinue: () -> Void
    let onScanAgain: () -> Void

    init(
        product: Product,
        firstProductForComparison: Product? = nil,
        languageProvider: LanguageProvider,
        analytics: AnalyticsServiceProtocol,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        onScanAgain: @escaping () -> Void
    ) {
        self._vm = StateObject(wrappedValue: ProductPreviewViewModel(
            product: product,
            firstProductForComparison: firstProductForComparison,
            languageProvider: languageProvider
        ))
        self.analytics = analytics
        self.onBack = onBack
        self.onContinue = onContinue
        self.onScanAgain = onScanAgain
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                PreviewImageSection(imageUrl: vm.imageUrl)
                
                VStack(alignment: .leading, spacing: 0) {
                    PreviewHeaderSection(name: vm.productName, brand: vm.brandName)
                    
                    PreviewConfirmCard()
                        .padding(.top, 24)
                        .padding(.horizontal, 28)
                    
                    PreviewActionButtons(
                        continueTitle: vm.continueButtonTitle,
                        onContinue: {
                            let mode = vm.firstProductForComparison != nil ? "comparison" : "details"
                            analytics.track(PreviewEvent.continueTap(mode: mode))
                            onContinue()
                        },
                        onScanAgain: {
                            analytics.track(PreviewEvent.scanAgainTap)
                            onScanAgain()
                        }
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 28)
                }
                
                Spacer()
            }
            
            PreviewTopBar(onBack: {
                analytics.track(PreviewEvent.backTap)
                onBack()
            })
        }
        .onAppear {
            analytics.track(PreviewEvent.screenView(barcode: vm.product.barcode))
        }
    }
}
