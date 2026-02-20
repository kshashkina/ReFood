import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            MainHeaderView(title: "Profile")
        }
    }
}
