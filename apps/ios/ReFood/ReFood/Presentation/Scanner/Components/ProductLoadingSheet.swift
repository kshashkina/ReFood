import SwiftUI

struct ProductLoadingSheet: View {
    @Binding var isPresented: Bool
    var progress: Double
    var currentStep: LoadingStep
    var isFailed: Bool = false
    
    let onFinish: () -> Void
    let onTryAgain: () -> Void
    let onAddProduct: () -> Void
    
    enum LoadingStep: Int, CaseIterable {
        case searching = 0
        case processing = 1
        case ready = 2
        
        var titleKey: String {
            switch self {
            case .searching: return "sheet_step_search_title"
            case .processing: return "sheet_step_process_title"
            case .ready: return "sheet_step_ready_title"
            }
        }
        
        var subtitleKey: String {
            switch self {
            case .searching: return "sheet_step_search_sub"
            case .processing: return "sheet_step_process_sub"
            case .ready: return "sheet_step_ready_sub"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.vertical, 12)
            
            HStack(spacing: 12) {
                headerIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(isFailed ? "sheet_error_title" : currentStep.titleKey))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isFailed ? .red : .white)
                    Text(LocalizedStringKey(isFailed ? "sheet_error_sub" : "sheet_looking"))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(isFailed ? Color.red : Color.appAccent)
                        .frame(width: max(0, min(CGFloat(progress) * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)), height: 8)
                        .shadow(color: (isFailed ? Color.red : Color.appAccent).opacity(0.6), radius: 6)
                }
                
                HStack {
                    Text(LocalizedStringKey("sheet_lbl_start")).foregroundColor(progress >= 0.1 ? (isFailed ? .red : Color.appAccent) : .gray)
                    Spacer()
                    Text(LocalizedStringKey(isFailed ? "sheet_lbl_error" : "sheet_lbl_found")).foregroundColor(isFailed ? .red : (progress >= 0.5 ? Color.appAccent : .gray))
                    Spacer()
                    Text(LocalizedStringKey("sheet_lbl_ready")).foregroundColor(progress >= 1.0 ? Color.appAccent : .gray)
                }
                .font(.system(size: 11, weight: .bold))
            }
            .padding(24)

            if isFailed {
                failureView
            } else {
                loadingStepsView
            }

            Spacer()

            actionButtons
        }
        .background(Color(red: 26/255, green: 26/255, blue: 26/255))
        .animation(.spring(), value: isFailed)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
        .animation(.easeInOut(duration: 0.5), value: currentStep)
    }

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill((isFailed ? Color.red : Color.appAccent).opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke((isFailed ? Color.red : Color.appAccent).opacity(0.2), lineWidth: 1))
            
            Image(systemName: isFailed ? "xmark" : (progress >= 1.0 ? "checkmark" : "magnifyingglass"))
                .foregroundColor(isFailed ? .red : Color.appAccent)
                .font(.system(size: 20, weight: .bold))
        }
    }

    private var loadingStepsView: some View {
        VStack(spacing: 12) {
            ForEach(LoadingStep.allCases, id: \.self) { step in
                StepRow(
                    step: step,
                    isActive: currentStep == step,
                    isCompleted: currentStep.rawValue > step.rawValue || (progress >= 1.0 && step == .ready)
                )
            }
        }
        .padding(.horizontal, 24)
    }

    private var failureView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 5)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 30)
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 18, weight: .ultraLight))
                        .foregroundColor(.red.opacity(0.8))
                }
            }
            
            VStack(spacing: 8) {
                Text(LocalizedStringKey("sheet_fail_title"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("sheet_fail_desc"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 5)
        }
        .padding(.horizontal, 24)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isFailed {
                Button(action: onTryAgain) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(LocalizedStringKey("sheet_btn_try_again"))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.red)
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.3), radius: 15)
                }
                
                Button(action: onAddProduct) {
                    HStack {
                        Image(systemName: "text.badge.plus")
                        Text(LocalizedStringKey("sheet_btn_add"))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 0.5))
                }
            } else if progress >= 1.0 {
                Button(action: onFinish) {
                    HStack {
                        Text(LocalizedStringKey("sheet_btn_view"))
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.appAccent)
                    .cornerRadius(16)
                    .shadow(color: Color.appAccent.opacity(0.4), radius: 15)
                }
            } else {
                Spacer().frame(height: 104)
            }
        }
        .padding(24)
    }
}

struct StepRow: View {
    let step: ProductLoadingSheet.LoadingStep
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted || isActive ? Color.appAccent.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(Color.appAccent)
                } else if isActive {
                    Circle().fill(Color.appAccent).frame(width: 8, height: 8)
                        .shadow(color: Color.appAccent, radius: 4)
                } else {
                    Text("\(step.rawValue + 1)").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.3))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(step.titleKey))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isActive || isCompleted ? .white : .white.opacity(0.35))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(LocalizedStringKey(step.subtitleKey))
                    .font(.system(size: 12))
                    .foregroundColor(isActive ? Color.appAccent.opacity(0.7) : .white.opacity(0.2))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 8)
            
            if isCompleted {
                Text("✓").foregroundColor(Color.appAccent).font(.system(size: 11, weight: .bold))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 72)
        .background(isActive ? Color.appAccent.opacity(0.08) : Color.white.opacity(0.02))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.appAccent.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}
