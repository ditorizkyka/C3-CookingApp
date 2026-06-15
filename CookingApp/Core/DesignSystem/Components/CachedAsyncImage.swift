

import SwiftUI

final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 100       
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func set(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL, cost: image.jpegData(compressionQuality: 1)?.count ?? 0)
    }
}

struct CachedAsyncImage: View {
    let url: URL

    @State private var loadedImage: UIImage? = nil
    @State private var hasFailed: Bool = false

    var body: some View {
        Group {
            if let img = loadedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else if hasFailed {
                ImagePlaceholder()
            } else {
                ProgressView()
            }
        }
        .task(id: url) {
            await load(url: url)
        }
    }

    private func load(url: URL) async {
        if let cached = ImageCache.shared.image(for: url) {
            loadedImage = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                hasFailed = true
                return
            }
            ImageCache.shared.set(uiImage, for: url)
            loadedImage = uiImage
        } catch {
            let nsErr = error as NSError
            if nsErr.code == NSURLErrorCancelled {
                print("Task cancelled (nav transition) for \(url.lastPathComponent) — will retry on next appear")
            } else {
                print("Failed to load \(url): \(error.localizedDescription)")
                hasFailed = true
            }
        }
    }
}
