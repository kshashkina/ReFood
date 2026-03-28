import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    
    private var activeRequests: [URL: Task<UIImage, Error>] = [:]

    func load(url: URL) async throws -> UIImage {
        if let cached = ImageCache.shared.image(for: url) {
            return cached
        }

        if let existingTask = activeRequests[url] {
            return try await existingTask.value
        }

        let task = Task<UIImage, Error> {
            var request = URLRequest(url: url)
            request.cachePolicy = .useProtocolCachePolicy
            request.timeoutInterval = 15
            
            request.setValue("EcoScanner - iOS - Version 1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            ImageCache.shared.insert(image, for: url)
            return image
        }

        activeRequests[url] = task
        
        do {
            let image = try await task.value
            activeRequests[url] = nil
            return image
        } catch {
            activeRequests[url] = nil
            throw error
        }
    }
}
