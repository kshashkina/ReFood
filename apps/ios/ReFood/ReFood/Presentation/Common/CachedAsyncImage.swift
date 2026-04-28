import SwiftUI
import UIKit

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    @ViewBuilder let placeholder: Placeholder

    @State private var uiImage: UIImage?
    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .task(id: url) {
            uiImage = nil
            guard let url = url else { return }
            
            do {
                let img = try await ImageLoader.shared.load(url: url)
                self.uiImage = img
            } catch {
                print("❌ Image load error: \(error.localizedDescription) for URL: \(url)")
            }
        }
    }
}
