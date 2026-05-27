import SwiftUI

struct HelpView: View {
    @StateObject private var vm: HelpViewModel
    let onBack: () -> Void
    
    init(emailService: EmailServiceProtocol, onBack: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: HelpViewModel(emailService: emailService))
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
                                onTap: { vm.toggleItem(item) }
                            )
                        }
                    }
                    
                    ContactEmailButton(action: {
                        vm.contactSupport()
                    })
                    .padding(.top, 8)
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 90)
                .padding(.bottom, 40)
            }
            
            HelpTopBar(onBack: onBack)
        }
        .navigationBarHidden(true)
    }
}
