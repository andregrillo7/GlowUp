import SwiftUI
import UIKit

/// Generates and caches downscaled thumbnails so photo grids don't
/// decode full-resolution images on every render.
enum ThumbnailCache {
    private static let cache = NSCache<NSString, UIImage>()

    /// Returns a downsampled thumbnail for the given image data, cached by key.
    static func thumbnail(for data: Data, key: String, maxPixel: CGFloat = 300) -> UIImage? {
        if let cached = cache.object(forKey: key as NSString) {
            return cached
        }
        guard let image = downsample(data: data, maxPixel: maxPixel) else { return nil }
        cache.setObject(image, forKey: key as NSString)
        return image
    }

    /// Uses ImageIO to decode a thumbnail at the target size without
    /// loading the full image into memory.
    private static func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }
        let scale = UIScreen.main.scale
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel * scale
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

/// A view that loads a downscaled thumbnail off the main thread.
struct ThumbnailImage: View {
    let data: Data
    let key: String
    var maxPixel: CGFloat = 300

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .task(id: key) {
            if image == nil {
                let loaded = await Task.detached(priority: .userInitiated) {
                    ThumbnailCache.thumbnail(for: data, key: key, maxPixel: maxPixel)
                }.value
                await MainActor.run { self.image = loaded }
            }
        }
    }
}
