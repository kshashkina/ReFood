import UIKit

actor ImageLoader {

    static let shared = ImageLoader()

    func load(url: URL) async throws -> UIImage {
        if let cached = ImageCache.shared.image(for: url) {
            return cached
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 30
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        ImageCache.shared.insert(image, for: url)
        return image
    }
}
