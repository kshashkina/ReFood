import SwiftUI

struct AddProductInputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboard: UIKeyboardType = .default
    var isRequired: Bool = false
    var focus: FocusState<Bool>.Binding
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(label))
                .font(.system(size: 14, weight: isRequired ? .bold : .semibold))
                .foregroundColor(isRequired ? .white : .white.opacity(0.6))
            TextField(LocalizedStringKey(placeholder), text: $text)
                .keyboardType(keyboard)
                .focused(focus)
                .inputStyle(accent: Color.appAccent)
                .simultaneousGesture(TapGesture().onEnded { onTap?() })
        }
    }
}

struct GradeSelectionView: View {
    let title: String
    @Binding var selection: String
    let grades = ["A", "B", "C", "D", "E"]
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(title)).font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.6))
            HStack(spacing: 10) {
                ForEach(grades, id: \.self) { grade in
                    let isSelected = selection == grade
                    let color = Color.grade(grade)
                    Button {
                        onTap?()
                        selection = isSelected ? "" : grade
                    } label: {
                        Text(grade).font(.system(size: 20, weight: .bold)).foregroundColor(isSelected ? color : .white.opacity(0.4))
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(isSelected ? color.opacity(0.13) : Color.white.opacity(0.05))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}

struct ErrorMessageView: View {
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            Text(LocalizedStringKey(text))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
    }
}

struct ImportantNoticeView: View {
    let isEditingMode: Bool
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle.fill").foregroundColor(Color.appAccent).font(.system(size: 18))
                VStack(alignment: .leading, spacing: 4) {
                    Text("addProduct_notice_title").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text(isEditingMode ? "addProduct_notice_edit" : "addProduct_notice_new")
                        .font(.system(size: 13)).foregroundColor(.white.opacity(0.7)).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appAccent.opacity(0.2), lineWidth: 1))
    }
}

struct HeaderDescriptionView: View {
    let isEditing: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isEditing ? "addProduct_header_edit" : "addProduct_header_new")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.appAccent)
            Text("addProduct_header_subtitle")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TopBarView: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .frame(height: 110)
                .overlay(
                    HStack {
                        CircleBackButton(action: onDismiss)
                            .padding(.leading, 24)
                        
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                )
            Spacer()
        }
        .ignoresSafeArea()
    }
}

struct SaveButtonView: View {
    @ObservedObject var vm: AddProductViewModel
    @Binding var showSuccess: Bool
    var isFocused: FocusState<Bool>.Binding
    var onTap: (() -> Void)? = nil
        
    var body: some View {
        Button {
            isFocused.wrappedValue = false
            if !showSuccess {
                onTap?()
                Task { await vm.saveProduct() }
            }
        } label: {
            HStack(spacing: 12) {
                if showSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .transition(.scale.combined(with: .opacity))
                } else if vm.isSaving {
                    ProgressView().tint(.black)
                } else {
                    Text(vm.isEditingMode ? "addProduct_save_edit" : "addProduct_save_new")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(vm.canSave ? .black : .white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: showSuccess ? 29 : 16)
                    .fill(showSuccess ? Color.appAccent : (vm.canSave ? Color.appAccent : Color.white.opacity(0.1)))
            )
            .frame(width: showSuccess ? 58 : nil)
            .scaleEffect(showSuccess ? 1.05 : 1.0)
        }
        .disabled(!vm.canSave || vm.isSaving || showSuccess)
        .shadow(color: (vm.canSave || showSuccess) ? Color.appAccent.opacity(showSuccess ? 0.5 : 0.3) : .clear, radius: showSuccess ? 20 : 15)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccess)
        .animation(.default, value: vm.isSaving)
    }
}
