import SwiftUI

struct PhotoSectionView: View {
    @ObservedObject var vm: AddProductViewModel
    @Binding var showCamera: Bool
    
    let flow: String
    let analytics: AnalyticsServiceProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles").foregroundColor(Color.appAccent)
                Text(vm.isEditingMode ? "addProduct_step1_title_edit" : "addProduct_step1_title_new")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Spacer()
            }
            Text(vm.isEditingMode ? "addProduct_step1_desc_edit" : "addProduct_step1_desc_new")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.6))
            
            Button {
                analytics.track(ProductChangeEvent.photoTap(flow: flow))
                showCamera = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)).frame(height: 160)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(vm.imageError != nil ? Color.red.opacity(0.5) : (vm.isImageValid ? Color.appAccent.opacity(0.5) : Color.white.opacity(0.1)), lineWidth: 2))
                    
                    if let image = vm.selectedUIImage {
                        Image(uiImage: image).resizable().scaledToFill().frame(height: 160).cornerRadius(20).clipped()
                            .blur(radius: vm.isUploadingImage ? 8 : 0)
                            .overlay(Color.black.opacity(vm.isUploadingImage ? 0.6 : 0).cornerRadius(20))
                    } else if vm.isEditingMode, let url = vm.existingImageUrl {
                        CachedAsyncImage(url: URL(string: url), contentMode: .fill) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo").font(.system(size: 30))
                                Text("addProduct_photo_no_image").font(.system(size: 14, weight: .medium))
                            }.foregroundColor(.white.opacity(0.3))
                        }.frame(height: 160).cornerRadius(20).clipped()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill").font(.system(size: 30))
                            Text("addProduct_photo_capture").font(.system(size: 14, weight: .medium))
                        }.foregroundColor(Color.appAccent)
                    }
                    
                    if vm.isUploadingImage {
                        VStack(spacing: 8) {
                            ProgressView().tint(Color.appAccent)
                            Text("addProduct_photo_analyzing").font(.system(size: 14, weight: .bold)).foregroundColor(Color.appAccent)
                        }
                    }
                    
                    if !vm.isUploadingImage && vm.isImageValid {
                        VStack { Spacer(); HStack { Spacer(); Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.palette).foregroundStyle(Color.black, Color.appAccent).font(.system(size: 32)).padding(12) } }
                    } else if !vm.isUploadingImage && vm.imageError != nil {
                        VStack { Spacer(); HStack { Spacer(); Image(systemName: "xmark.circle.fill").symbolRenderingMode(.palette).foregroundStyle(.white, .red).font(.system(size: 32)).padding(12) } }
                    }
                }
                .shadow(color: photoShadowColor, radius: 15)
            }.buttonStyle(.plain)
            
            if let imageErr = vm.imageError {
                ErrorMessageView(text: imageErr)
            }
        }
    }
    
    private var photoShadowColor: Color {
        if vm.isUploadingImage { return .clear }
        if vm.imageError != nil { return Color.red.opacity(0.6) }
        if vm.isImageValid { return Color.appAccent.opacity(0.6) }
        return .clear
    }
}

struct NutritionSectionView: View {
    @Binding var nutrition: NutritionFormFields
    var focus: FocusState<Bool>.Binding
    
    let flow: String
    let analytics: AnalyticsServiceProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("addProduct_nutrition_title").font(.system(size: 14, weight: .bold)).foregroundColor(Color.appAccent).padding(.leading, 4)
            GlassCard(cornerRadius: 20, padding: 20) {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        AddProductInputField(label: "addProduct_label_kcal", text: $nutrition.kcal, placeholder: "0", keyboard: .decimalPad, isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.kcalTap(flow: flow)) })
                        AddProductInputField(label: "addProduct_label_proteins", text: $nutrition.proteins, placeholder: "0", keyboard: .decimalPad, isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.proteinsTap(flow: flow)) })
                    }
                    HStack(spacing: 16) {
                        AddProductInputField(label: "addProduct_label_fats", text: $nutrition.fats, placeholder: "0", keyboard: .decimalPad, isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.fatsTap(flow: flow)) })
                        AddProductInputField(label: "addProduct_label_carbs", text: $nutrition.carbs, placeholder: "0", keyboard: .decimalPad, isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.carbsTap(flow: flow)) })
                    }
                    Divider().background(Color.white.opacity(0.1))
                    HStack(spacing: 16) {
                        AddProductInputField(label: "addProduct_label_sat_fat", text: $nutrition.saturatedFat, placeholder: "0", keyboard: .decimalPad, focus: focus, onTap: { analytics.track(ProductChangeEvent.satFatTap(flow: flow)) })
                        AddProductInputField(label: "addProduct_label_sugars", text: $nutrition.sugars, placeholder: "0", keyboard: .decimalPad, focus: focus, onTap: { analytics.track(ProductChangeEvent.sugarsTap(flow: flow)) })
                    }
                    HStack(spacing: 16) {
                        AddProductInputField(label: "addProduct_label_added_sugars", text: $nutrition.addedSugars, placeholder: "0", keyboard: .decimalPad, focus: focus, onTap: { analytics.track(ProductChangeEvent.addedSugarsTap(flow: flow)) })
                        AddProductInputField(label: "addProduct_label_salt", text: $nutrition.salt, placeholder: "0", keyboard: .decimalPad, focus: focus, onTap: { analytics.track(ProductChangeEvent.saltTap(flow: flow)) })
                    }
                    AddProductInputField(label: "addProduct_label_caffeine", text: $nutrition.caffeine, placeholder: "0", keyboard: .decimalPad, focus: focus, onTap: { analytics.track(ProductChangeEvent.caffeineTap(flow: flow)) })
                }
            }
        }
    }
}

struct GeneralInfoSectionView: View {
    @Binding var form: ProductFormModel
    let barcode: String
    var focus: FocusState<Bool>.Binding
    
    let flow: String
    let analytics: AnalyticsServiceProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.clipboard").foregroundColor(Color.appAccent)
                Text("addProduct_step2_title").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            }
            Text("addProduct_step2_desc").font(.system(size: 14)).foregroundColor(.white.opacity(0.6))
            
            GlassCard(cornerRadius: 20, padding: 20) {
                VStack(spacing: 16) {
                    AddProductInputField(label: "addProduct_label_name", text: $form.name, placeholder: "addProduct_placeholder_name", isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.nameTap(flow: flow)) })
                    AddProductInputField(label: "addProduct_label_brand", text: $form.brand, placeholder: "addProduct_placeholder_brand", isRequired: true, focus: focus, onTap: { analytics.track(ProductChangeEvent.brandTap(flow: flow)) })
                    AddProductInputField(label: "addProduct_label_quantity", text: $form.quantity, placeholder: "addProduct_placeholder_quantity", focus: focus, onTap: { analytics.track(ProductChangeEvent.quantityTap(flow: flow)) })
                    AddProductInputField(label: "addProduct_label_categories", text: $form.categories, placeholder: "addProduct_placeholder_categories", focus: focus, onTap: { analytics.track(ProductChangeEvent.categoryTap(flow: flow)) })
                    
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("addProduct_barcode_label \(barcode)")
                        Spacer()
                    }.font(.system(size: 13, weight: .medium)).foregroundColor(Color.appAccent).padding(12).background(Color.appAccent.opacity(0.1)).cornerRadius(10)
                }
            }
        }
    }
}

struct PackagingSectionView: View {
    @Binding var packaging: [PackagingInput]
    let onAdd: () -> Void
    var focus: FocusState<Bool>.Binding
    
    let flow: String
    let analytics: AnalyticsServiceProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("addProduct_packaging_title").font(.system(size: 14, weight: .bold)).foregroundColor(Color.appAccent)
                    Text("addProduct_packaging_desc").font(.system(size: 14)).foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Button(action: {
                    analytics.track(ProductChangeEvent.packagingAddTap(flow: flow))
                    onAdd()
                }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color.appAccent).font(.system(size: 20))
                }
            }.padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(Array(packaging.enumerated()), id: \.element.id) { index, _ in
                    GlassCard(cornerRadius: 16, padding: 12) {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                TextField(LocalizedStringKey("addProduct_label_shape"), text: $packaging[index].shape)
                                    .focused(focus)
                                    .inputStyle(accent: Color.appAccent)
                                    .simultaneousGesture(TapGesture().onEnded { analytics.track(ProductChangeEvent.packagingShapeTap(flow: flow)) })
                                TextField(LocalizedStringKey("addProduct_label_material"), text: $packaging[index].material)
                                    .focused(focus)
                                    .inputStyle(accent: Color.appAccent)
                                    .simultaneousGesture(TapGesture().onEnded { analytics.track(ProductChangeEvent.packagingMaterialTap(flow: flow)) })
                            }
                            TextField(LocalizedStringKey("addProduct_label_recycling_code"), text: $packaging[index].recycling)
                                .focused(focus)
                                .inputStyle(accent: Color.appAccent)
                                .simultaneousGesture(TapGesture().onEnded { analytics.track(ProductChangeEvent.packagingCodeTap(flow: flow)) })
                        }
                    }
                }
            }
        }
    }
}

struct IngredientsSectionView: View {
    @Binding var form: ProductFormModel
    var focus: FocusState<Bool>.Binding
    
    let flow: String
    let analytics: AnalyticsServiceProtocol
    
    var body: some View {
        GlassCard(cornerRadius: 20, padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("addProduct_ingredients_title")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("addProduct_ingredients_desc")
                        .font(.system(size: 14))
                        .foregroundColor(Color.appAccent.opacity(0.8))
                    
                    TextEditor(text: $form.ingredients)
                        .focused(focus)
                        .frame(height: 80)
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(Color.appAccent)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .simultaneousGesture(TapGesture().onEnded { analytics.track(ProductChangeEvent.ingredientsTap(flow: flow)) })
                }
                
                AddProductInputField(
                    label: "addProduct_label_allergens",
                    text: $form.allergens,
                    placeholder: "addProduct_placeholder_allergens",
                    focus: focus,
                    onTap: { analytics.track(ProductChangeEvent.allergensTap(flow: flow)) }
                )
            }
        }
    }
}
