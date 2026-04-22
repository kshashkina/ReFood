import SwiftUI

struct AddProductScreen: View {
    @StateObject private var vm: AddProductViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    @State private var showSuccessCheckmark = false
    
    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)
    
    init(barcode: String) {
        _vm = StateObject(wrappedValue: AddProductViewModel(barcode: barcode))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerDescription
                        .padding(.top, 110)
                    
                    GlassCard(cornerRadius: 20, padding: 20) {
                        VStack(spacing: 16) {
                            inputField("Product Name", text: $vm.name, placeholder: "e.g. Greek Yogurt", isRequired: true)
                                .focused($isFocused)
                            inputField("Brand", text: $vm.brand, placeholder: "e.g. Danone", isRequired: true)
                                .focused($isFocused)
                            inputField("Quantity", text: $vm.quantity, placeholder: "Include units (e.g. 500g, 1.5L)", isRequired: false)
                                .focused($isFocused)
                            inputField("Categories", text: $vm.categories, placeholder: "Separated by comma (e.g. Dairy, Yogurts)")
                                .focused($isFocused)
                            barcodeBadge
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        gradeSection(title: "Nutri-Score", selection: $vm.nutriScore)
                        gradeSection(title: "Eco-Score", selection: $vm.ecoScore)
                    }
                    
                    GlassCard(cornerRadius: 20, padding: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ingredients")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("List ingredients separated by commas")
                                    .font(.system(size: 12))
                                    .foregroundColor(accent.opacity(0.8))
                                TextEditor(text: $vm.ingredients)
                                    .focused($isFocused)
                                    .frame(height: 80)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .tint(accent)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            inputField("Allergens", text: $vm.allergens, placeholder: "e.g. Milk, Nuts, Soy")
                                .focused($isFocused)
                        }
                    }
                    
                    packagingSectionView
                    nutritionSectionView
                    
                    if vm.error != nil {
                        errorMessage("Our system cannot handle this input. Please check the fields and try again.")
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity.combined(with: .scale(scale: 0.9))
                            ))
                    }
                    
                    saveButton.padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8), value: vm.error)
            
            topBar
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { isFocused = false }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accent)
                }
            }
        }
        .onReceive(vm.$isSuccess) { success in
            if success {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSuccessCheckmark = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    dismiss()
                }
            }
        }
    }
    
    private var packagingSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Packaging").font(.system(size: 14, weight: .bold)).foregroundColor(accent)
                    Text("Use recycling codes (e.g. PAP 20, PET 01)").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Button(action: { vm.addPackagingField() }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(accent).font(.system(size: 20))
                }
            }.padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(Array(vm.packagingItems.enumerated()), id: \.element.id) { index, _ in
                    GlassCard(cornerRadius: 16, padding: 12) {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                TextField("Shape", text: $vm.packagingItems[index].shape).focused($isFocused).inputStyle(accent: accent)
                                TextField("Material", text: $vm.packagingItems[index].material).focused($isFocused).inputStyle(accent: accent)
                            }
                            TextField("Recycling Code", text: $vm.packagingItems[index].recycling).focused($isFocused).inputStyle(accent: accent)
                        }
                    }
                }
            }
        }
    }
    
    private var nutritionSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Facts (per 100g)").font(.system(size: 14, weight: .bold)).foregroundColor(accent).padding(.leading, 4)
            GlassCard(cornerRadius: 20, padding: 20) {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        inputField("Kcal", text: $vm.kcal, placeholder: "0", keyboard: .decimalPad, isRequired: true).focused($isFocused)
                        inputField("Proteins", text: $vm.proteins, placeholder: "0", keyboard: .decimalPad, isRequired: true).focused($isFocused)
                    }
                    HStack(spacing: 16) {
                        inputField("Fats", text: $vm.fats, placeholder: "0", keyboard: .decimalPad, isRequired: true).focused($isFocused)
                        inputField("Carbs", text: $vm.carbs, placeholder: "0", keyboard: .decimalPad, isRequired: true).focused($isFocused)
                    }
                    Divider().background(Color.white.opacity(0.1))
                    HStack(spacing: 16) {
                        inputField("Sat. Fat", text: $vm.saturatedFat, placeholder: "0", keyboard: .decimalPad).focused($isFocused)
                        inputField("Sugars", text: $vm.sugars, placeholder: "0", keyboard: .decimalPad).focused($isFocused)
                    }
                    HStack(spacing: 16) {
                        inputField("Added Sugars", text: $vm.addedSugars, placeholder: "0", keyboard: .decimalPad).focused($isFocused)
                        inputField("Salt", text: $vm.salt, placeholder: "0", keyboard: .decimalPad).focused($isFocused)
                    }
                    inputField("Caffeine (mg)", text: $vm.caffeine, placeholder: "0", keyboard: .decimalPad).focused($isFocused)
                }
            }
        }
    }

    private var headerDescription: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Help the community").font(.system(size: 24, weight: .bold)).foregroundColor(accent)
            Text("Fields in **bold** are required. Please be as accurate as possible.").font(.system(size: 14)).foregroundColor(.white.opacity(0.5))
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputField(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default, isRequired: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 14, weight: isRequired ? .bold : .semibold)).foregroundColor(isRequired ? .white : .white.opacity(0.6))
            TextField(placeholder, text: text).keyboardType(keyboard).inputStyle(accent: accent)
        }
    }

    private func gradeSection(title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.6))
            HStack(spacing: 10) {
                ForEach(vm.grades, id: \.self) { grade in
                    let isSelected = selection.wrappedValue == grade
                    let color = gradeColor(grade)
                    Button { selection.wrappedValue = isSelected ? "" : grade } label: {
                        Text(grade).font(.system(size: 20, weight: .bold)).foregroundColor(isSelected ? color : .white.opacity(0.4))
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(isSelected ? color.opacity(0.13) : Color.white.opacity(0.05))
                            .cornerRadius(14).overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    private func gradeColor(_ grade: String) -> Color {
        switch grade.lowercased() {
        case "a": return Color(red: 144/255, green: 240/255, blue: 71/255)
        case "b": return Color(red: 179/255, green: 243/255, blue: 87/255)
        case "c": return Color(red: 245/255, green: 221/255, blue: 77/255)
        case "d": return Color(red: 255/255, green: 163/255, blue: 62/255)
        case "e": return Color(red: 255/255, green: 84/255,  blue: 84/255)
        default: return Color.white.opacity(0.45)
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.black.opacity(0.7)).frame(height: 110)
                .overlay(
                    HStack {
                        Button(action: { dismiss() }) {
                            Circle().fill(Color.white.opacity(0.1)).frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                .overlay(Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundColor(.white))
                        }.padding(.leading, 24)
                        Text("New Product").font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(.leading, 8)
                        Spacer()
                    }.padding(.top, 50)
                )
            Spacer()
        }.ignoresSafeArea()
    }

    private var barcodeBadge: some View {
        HStack {
            Image(systemName: "barcode.viewfinder")
            Text("Barcode: \(vm.barcode)")
            Spacer()
        }.font(.system(size: 13, weight: .medium)).foregroundColor(accent).padding(12).background(accent.opacity(0.1)).cornerRadius(10)
    }

    private func errorMessage(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(text)
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

    private var saveButton: some View {
        Button {
            isFocused = false
            if !showSuccessCheckmark {
                Task { await vm.saveProduct() }
            }
        } label: {
            HStack(spacing: 12) {
                if showSuccessCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .transition(.scale.combined(with: .opacity))
                } else if vm.isSaving {
                    ProgressView().tint(.black)
                } else {
                    Text("Save to Database")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(vm.canSave ? .black : .white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: showSuccessCheckmark ? 29 : 16)
                    .fill(showSuccessCheckmark ? accent : (vm.canSave ? accent : Color.white.opacity(0.1)))
            )
            .frame(width: showSuccessCheckmark ? 58 : nil)
            .scaleEffect(showSuccessCheckmark ? 1.05 : 1.0)
        }
        .disabled(!vm.canSave || vm.isSaving || showSuccessCheckmark)
        .shadow(color: (vm.canSave || showSuccessCheckmark) ? accent.opacity(showSuccessCheckmark ? 0.5 : 0.3) : .clear, radius: showSuccessCheckmark ? 20 : 15)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessCheckmark)
        .animation(.default, value: vm.isSaving)
    }
}

extension View {
    func inputStyle(accent: Color) -> some View {
        self.padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
            .tint(accent)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
