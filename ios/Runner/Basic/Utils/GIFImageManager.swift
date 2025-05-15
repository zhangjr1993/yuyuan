import UIKit

class GIFImageManager {
    static let shared = GIFImageManager()
    
    private var imageCache: [String: [UIImage]] = [:]
    
    private init() {}
    
    func loadGIF(named name: String) -> [UIImage]? {
        // 如果缓存中存在，直接返回
        if let cachedImages = imageCache[name] {
            return cachedImages
        }
        
        // 加载GIF文件
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        // 解析GIF的每一帧
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        // 缓存结果
        imageCache[name] = images
        return images
    }
} 