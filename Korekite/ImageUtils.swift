import UIKit
import SwiftUI

struct ImageUtils {
    
    // 画像をスクエアにクロップ
    static func squareCrop(_ image: UIImage) -> UIImage? {
        let size = min(image.size.width, image.size.height)
        let origin = CGPoint(
            x: (image.size.width - size) / 2,
            y: (image.size.height - size) / 2
        )
        
        guard let cgImage = image.cgImage?.cropping(to: CGRect(
            origin: origin,
            size: CGSize(width: size, height: size)
        )) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // 画像を指定サイズにリサイズ
    static func resize(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 画像を圧縮してDataに変換
    static func compress(_ image: UIImage, quality: CGFloat = 0.8, maxSizeKB: Int = 1024) -> Data? {
        var compressionQuality = quality
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        // 指定サイズを超える場合は圧縮率を下げる
        while let data = imageData, data.count > maxSizeKB * 1024 && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        return imageData
    }
    
    // 画像をリサイズして圧縮
    static func processForStorage(_ image: UIImage, targetSize: CGSize = CGSize(width: 512, height: 512)) -> Data? {
        guard let resizedImage = resize(image, to: targetSize) else {
            return compress(image)
        }
        return compress(resizedImage)
    }
    
    // DataからUIImageを作成
    static func imageFromData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // 画像のサイズ情報を取得
    static func getImageInfo(_ image: UIImage) -> (width: CGFloat, height: CGFloat, sizeKB: Int?) {
        let width = image.size.width
        let height = image.size.height
        let sizeKB: Int? = {
            if let data = image.jpegData(compressionQuality: 1.0) {
                return data.count / 1024
            }
            return nil
        }()
        
        return (width, height, sizeKB)
    }
}