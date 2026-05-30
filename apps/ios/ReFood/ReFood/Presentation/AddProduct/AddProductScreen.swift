import SwiftUI

struct AddProductScreen: View {
    @StateObject private var vm: AddProductViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    @State private var showSuccessCheckmark = false
    @State private var showCamera = false
    
    let analytics: AnalyticsServiceProtocol
    
    init(
        barcode: String,
        existingProduct: Product? = nil,
        repository: ProductRepository,
        uploadService: ImageUploadServicing,
        metricsRepository: MetricsRepositoryProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        _vm = StateObject(wrappedValue: AddProductViewModel(
            barcode: barcode,
            existingProduct: existingProduct,
            repository: repository,
            uploadService: uploadService,
            metricsRepository: metricsRepository
        ))
        self.analytics = analytics
    }
    
    var flow: String { vm.isEditingMode ? "edit" : "add" }
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HeaderDescriptionView(isEditing: vm.isEditingMode)
                        .padding(.top, 70)
                    
                    PhotoSectionView(vm: vm, showCamera: $showCamera, flow: flow, analytics: analytics)
                    
                    GeneralInfoSectionView(form: $vm.form, barcode: vm.barcode, focus: $isFocused, flow: flow, analytics: analytics)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        GradeSelectionView(title: "Nutri-Score", selection: $vm.form.nutriScore, onTap: { analytics.track(ProductChangeEvent.nutriTap(flow: flow)) })
                        GradeSelectionView(title: "Eco-Score", selection: $vm.form.ecoScore, onTap: { analytics.track(ProductChangeEvent.ecoTap(flow: flow)) })
                    }
                    
                    IngredientsSectionView(form: $vm.form, focus: $isFocused, flow: flow, analytics: analytics)
                    
                    PackagingSectionView(packaging: $vm.form.packaging, onAdd: vm.addPackagingField, focus: $isFocused, flow: flow, analytics: analytics)
                    
                    NutritionSectionView(nutrition: $vm.form.nutrition, focus: $isFocused, flow: flow, analytics: analytics)
                    
                    ImportantNoticeView(isEditingMode: vm.isEditingMode)
                    
                    VStack(spacing: 8) {
                        if vm.error != nil {
                            ErrorMessageView(text: "addProduct_error_system")
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity.combined(with: .scale(scale: 0.9))))
                        }
                        
                        SaveButtonView(
                            vm: vm,
                            showSuccess: $showSuccessCheckmark,
                            isFocused: $isFocused,
                            onTap: { analytics.track(ProductChangeEvent.continueTap(flow: flow)) }
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
                onDismiss: {
                    analytics.track(ProductChangeEvent.backTap(flow: flow))
                    dismiss()
                }
            )
        }
        .onAppear {
            analytics.track(ProductChangeEvent.screenView(flow: flow))
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
