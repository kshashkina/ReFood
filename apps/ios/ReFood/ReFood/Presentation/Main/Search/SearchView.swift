import SwiftUI

struct SearchView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            MainHeaderView(title: "Search")
        }
    }
}
