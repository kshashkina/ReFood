import SwiftUI

struct MainContainerView: View {

    @State private var selectedTab: MainTab = .home
    @StateObject private var vm = MainContainerViewModel()

    var body: some View {
        ZStack {
            content
                .ignoresSafeArea()

            VStack {
                Spacer()
                MainTabBar(
                    onTapScanner: { vm.onTapScan()}, selected: $selectedTab
                )
                .padding(.bottom, 16)
            }

            if vm.isCameraAccessModalPresented {
                CameraAccessModalView(
                    isPresented: $vm.isCameraAccessModalPresented,
                    onOpenSettings: { vm.openAppSettings() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isCameraAccessModalPresented)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home: HomeView()
        case .search: SearchView()
        case .map: MapView()
        case .profile: ProfileView()
        }
    }
}
