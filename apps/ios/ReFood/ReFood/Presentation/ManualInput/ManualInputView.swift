import SwiftUI

public struct ManualInputView: View {
    @ObservedObject var vm: ManualInputViewModel
    @FocusState private var isFocused: Bool
    
    let analytics: AnalyticsServiceProtocol
    let onClose: () -> Void
    let onFind: () -> Void

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    CircleBackButton {
                        analytics.track(ManualInputEvent.backTap)
                        onClose()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        ManualInputTitleGroup()
                        ManualInputFeatureCard()
                        
                        ManualInputTextField(
                            text: $vm.barcode,
                            focus: $isFocused,
                            onFilter: { newValue in
                                vm.updateBarcode(with: newValue)
                            },
                            onDoneTap: {
                                analytics.track(ManualInputEvent.doneTap)
                            }
                        )
                        
                        BarcodeTipView()
                        
                        Button {
                            isFocused = false
                            analytics.track(ManualInputEvent.continueTap)
                            onFind()
                        } label: {
                            Text("manualInput_button_find")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(vm.isInputValid ? Color.appAccent : Color.white.opacity(0.1))
                                .cornerRadius(16)
                        }
                        .disabled(!vm.isInputValid)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .onChange(of: vm.isLoading) { loading in
            if !loading {
                isFocused = true
            }
        }
        .onChange(of: isFocused) { focused in
            if focused {
                analytics.track(ManualInputEvent.formTap)
            }
        }
    }
}
