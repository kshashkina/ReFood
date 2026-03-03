import SwiftUI
import UIKit

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    @ViewBuilder let placeholder: Placeholder

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder()
    }

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
            await load()
        }
    }

    @MainActor
    private func load() async {
        guard let url else { return }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let img = try await ImageLoader.shared.load(url: url)
            self.uiImage = img
        } catch {}
    }
}
