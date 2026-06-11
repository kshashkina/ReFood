import SwiftUI

struct SettingsView: View {
    @StateObject private var vm: SettingsViewModel
    @State private var showDeleteAlert = false
    let analytics: AnalyticsServiceProtocol
    let onBack: () -> Void
    
    private let termsURL = "https://refood-docs-v1.s3.eu-north-1.amazonaws.com/public/terms-of-service.html"
    private let privacyURL = "https://refood-docs-v1.s3.eu-north-1.amazonaws.com/public/privacy-policy.html"
    
    init(deleteAccountUseCase: DeleteAccountUseCase, localStorage: LocalStorageProtocol, analytics: AnalyticsServiceProtocol, onBack: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: SettingsViewModel(
            deleteAccountUseCase: deleteAccountUseCase,
            localStorage: localStorage
        ))
        self.analytics = analytics
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    SettingsSectionView(title: String(localized: "settings_section_permissions")) {
                        SettingsRowButton(icon: "camera", title: String(localized: "settings_permission_camera")) {
                            analytics.track(SettingsEvent.cameraTap)
                            vm.openSystemSettings()
                        }
                        SettingsRowButton(icon: "location", title: String(localized: "settings_permission_location")) {
                            analytics.track(SettingsEvent.locationTap)
                            vm.openSystemSettings()
                        }
                    }
                    
                    SettingsSectionView(title: String(localized: "settings_section_legal")) {
                        SettingsRowButton(icon: "doc.text", title: String(localized: "settings_legal_terms")) {
                            analytics.track(SettingsEvent.termsTap)
                            vm.openURL(termsURL)
                        }
                        SettingsRowButton(icon: "shield", title: String(localized: "settings_legal_privacy")) {
                            analytics.track(SettingsEvent.privacyTap)
                            vm.openURL(privacyURL)
                        }
                    }
                    
                    if vm.isLinked {
                        SettingsSectionView(title: String(localized: "settings_section_danger")) {
                            SettingsRowButton(
                                icon: "trash",
                                title: String(localized: "settings_delete_account"),
                                iconTint: .red,
                                bgTint: Color.red.opacity(0.1),
                                borderTint: Color.red.opacity(0.3)
                            ) {
                                analytics.track(SettingsEvent.deleteAccountTap)
                                showDeleteAlert = true
                            }
                        }
                    }
                    
                    Text(vm.appVersion)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 24)
                .padding(.top, 110)
            }
            
            SettingsHeaderView(title: String(localized: "settings_title"), onBack: {
                analytics.track(SettingsEvent.backTap)
                onBack()
            })
            
            if vm.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            let state = vm.isLinked ? "in" : "out"
            analytics.track(SettingsEvent.screenView(state: state))
        }
        .onChange(of: showDeleteAlert) { isPresented in
            if isPresented {
                analytics.track(SettingsEvent.deleteAccountModalView)
            }
        }
        .alert(String(localized: "settings_delete_account"), isPresented: $showDeleteAlert) {
            Button(String(localized: "alert_cancel"), role: .cancel) {
                analytics.track(SettingsEvent.deleteAccountCancelTap)
            }
            Button(String(localized: "alert_delete"), role: .destructive) {
                analytics.track(SettingsEvent.deleteAccountConfirmTap)
                vm.deleteAccount()
            }
        } message: {
            Text(String(localized: "settings_delete_alert_message"))
        }
    }
}
