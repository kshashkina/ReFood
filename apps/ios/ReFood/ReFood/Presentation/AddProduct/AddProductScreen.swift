import SwiftUI

struct AddProductScreen: View {
    @StateObject private var vm: AddProductViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    @State private var showSuccessCheckmark = false
    @State private var showCamera = false
    
    
    init(
        barcode: String,
        existingProduct: Product? = nil,
        repository: ProductRepository,
        uploadService: ImageUploadServicing
    ) {
        _vm = StateObject(wrappedValue: AddProductViewModel(
            barcode: barcode,
            existingProduct: existingProduct,
            repository: repository,
            uploadService: uploadService
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HeaderDescriptionView(isEditing: vm.isEditingMode)
                        .padding(.top, 70)
                    
                    PhotoSectionView(vm: vm, showCamera: $showCamera)
                    
                    GeneralInfoSectionView(form: $vm.form, barcode: vm.barcode, focus: $isFocused)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        GradeSelectionView(title: "Nutri-Score", selection: $vm.form.nutriScore)
                        GradeSelectionView(title: "Eco-Score", selection: $vm.form.ecoScore)
                    }
                    
                    IngredientsSectionView(form: $vm.form, focus: $isFocused)
                    
                    PackagingSectionView(packaging: $vm.form.packaging, onAdd: vm.addPackagingField, focus: $isFocused)
                    
                    NutritionSectionView(nutrition: $vm.form.nutrition, focus: $isFocused)
                    
                    ImportantNoticeView(isEditingMode: vm.isEditingMode)
                    
                    VStack(spacing: 8) {
                        if vm.error != nil {
                            ErrorMessageView(text: "addProduct_error_system")
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity.combined(with: .scale(scale: 0.9))))
                        }
                        
                        SaveButtonView(
                            vm: vm,
                            showSuccess: $showSuccessCheckmark,
                            isFocused: $isFocused
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8), value: vm.error)
            .animation(.interactiveSpring(), value: vm.imageError)
            .animation(.interactiveSpring(), value: vm.isUploadingImage)
            
            TopBarView(
                title: vm.isEditingMode ? "addProduct_title_edit" : "addProduct_title_new",
                onDismiss: { dismiss() }
            )
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(image: $vm.selectedUIImage).ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack { Spacer(); Button("common_done") { isFocused = false }.font(.system(size: 16, weight: .bold)).foregroundColor(Color.appAccent) }
            }
        }
        .onReceive(vm.$isSuccess) { success in
            if success {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSuccessCheckmark = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { dismiss() }
            }
        }
    }
}
