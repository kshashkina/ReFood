import SwiftUI

struct HelpView: View {
    @StateObject private var vm: HelpViewModel
    let analytics: AnalyticsServiceProtocol
    let onBack: () -> Void
    
    init(emailService: EmailServiceProtocol, analytics: AnalyticsServiceProtocol, onBack: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: HelpViewModel(emailService: emailService))
        self.analytics = analytics
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ForEach(vm.faqItems) { item in
                            FAQItemView(
                                item: item,
                                isExpanded: vm.expandedItemId == item.id,
                                onTap: {
                                    analytics.track(HelpEvent.faqTap(id: item.index))
                                    vm.toggleItem(item)
                                }
                            )
                        }
                    }
                    
                    ContactEmailButton(action: {
                        analytics.track(HelpEvent.emailTap)
                        vm.contactSupport()
                    })
                    .padding(.top, 8)
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 90)
                .padding(.bottom, 40)
            }
            
            HelpTopBar(onBack: {
                analytics.track(HelpEvent.backTap)
                onBack()
            })
        }
        .navigationBarHidden(true)
        .onAppear {
            analytics.track(HelpEvent.screenView)
        }
    }
}
