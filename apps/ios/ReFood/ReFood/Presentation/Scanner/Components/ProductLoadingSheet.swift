import SwiftUI

struct ProductLoadingSheet: View {
    @Binding var isPresented: Bool
    var progress: Double
    var currentStep: LoadingStep
    var isFailed: Bool = false
    
    let onFinish: () -> Void
    let onTryAgain: () -> Void
    let onAddProduct: () -> Void
    
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    private let errorColor = Color(red: 255/255, green: 59/255, blue: 48/255)
    
    enum LoadingStep: Int, CaseIterable {
        case searching = 0
        case processing = 1
        case ready = 2
        
        var title: String {
            switch self {
            case .searching: return "Starting search..."
            case .processing: return "Product found"
            case .ready: return "Product ready!"
            }
        }
        
        var subtitle: String {
            switch self {
            case .searching: return "Searching for your product in the database..."
            case .processing: return "Preparing information about your product..."
            case .ready: return "All information has been successfully loaded"
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
                    Text(isFailed ? "Search error" : currentStep.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isFailed ? errorColor : .white)
                    Text(isFailed ? "Could not find your product in the database" : "Looking for your product...")
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
                        .fill(isFailed ? errorColor : accent)
                        .frame(width: max(0, min(CGFloat(progress) * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)), height: 8)
                        .shadow(color: (isFailed ? errorColor : accent).opacity(0.6), radius: 6)
                }
                
                HStack {
                    Text("Start").foregroundColor(progress >= 0.1 ? (isFailed ? errorColor : accent) : .gray)
                    Spacer()
                    Text(isFailed ? "Error" : "Found").foregroundColor(isFailed ? errorColor : (progress >= 0.5 ? accent : .gray))
                    Spacer()
                    Text("Ready").foregroundColor(progress >= 1.0 ? accent : .gray)
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
    }

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill((isFailed ? errorColor : accent).opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke((isFailed ? errorColor : accent).opacity(0.2), lineWidth: 1))
            
            Image(systemName: isFailed ? "xmark" : (progress >= 1.0 ? "checkmark" : "magnifyingglass"))
                .foregroundColor(isFailed ? errorColor : accent)
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
            VStack(spacing: 10) {
                Text("Product not found")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("This product has not yet been added to our database. You can try again or enter the information manually.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isFailed {
                Button(action: onTryAgain) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(errorColor)
                    .cornerRadius(16)
                    .shadow(color: errorColor.opacity(0.3), radius: 15)
                }
                
                Button(action: onAddProduct) {
                    HStack {
                        Image(systemName: "text.badge.plus")
                        Text("Add product to the database")
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
                        Text("View Product")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(accent)
                    .cornerRadius(16)
                    .shadow(color: accent.opacity(0.4), radius: 15)
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
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted || isActive ? accent.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(accent)
                } else if isActive {
                    Circle().fill(accent).frame(width: 8, height: 8)
                        .shadow(color: accent, radius: 4)
                } else {
                    Text("\(step.rawValue + 1)").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.3))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isActive || isCompleted ? .white : .white.opacity(0.35))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(step.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(isActive ? accent.opacity(0.7) : .white.opacity(0.2))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 8)
            
            if isCompleted {
                Text("✓").foregroundColor(accent).font(.system(size: 11, weight: .bold))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 72)
        .background(isActive ? accent.opacity(0.08) : Color.white.opacity(0.02))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? accent.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}
