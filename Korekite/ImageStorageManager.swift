import Foundation
import UIKit

class ImageStorageManager {
    static let shared = ImageStorageManager()
    private init() {}
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent("Images")
    }
    
    // MARK: - Public Methods
    
    func saveImage(_ imageData: Data, for outfitId: UUID) -> String? {
        do {
            try createImagesDirectoryIfNeeded()
            let filename = "\(outfitId.uuidString).jpg"
            let fileURL = imagesDirectory.appendingPathComponent(filename)
            try imageData.write(to: fileURL)
            print("Image saved successfully: \(filename)")
            return filename
        } catch {
            print("Error saving image for outfit \(outfitId): \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage(filename: String) -> Data? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error loading image \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        do {
            try fileManager.removeItem(at: fileURL)
            print("Image deleted successfully: \(filename)")
        } catch {
            print("Error deleting image \(filename): \(error.localizedDescription)")
        }
    }
    
    func migrateFromUserDefaults(outfits: [Outfit]) -> [Outfit] {
        var migratedOutfits: [Outfit] = []
        
        for outfit in outfits {
            var updatedOutfit = outfit
            
            if let imageData = outfit.imageData,
               let uiImage = UIImage(data: imageData),
               let compressedData = ImageUtils.processForStorage(uiImage) {
                // 画像データを圧縮してファイルに保存
                if let filename = saveImage(compressedData, for: outfit.id) {
                    updatedOutfit.imageFilename = filename
                    updatedOutfit.imageData = nil // UserDefaultsから削除
                }
            }
            
            migratedOutfits.append(updatedOutfit)
        }
        
        return migratedOutfits
    }
    
    // MARK: - Private Methods
    
    private func createImagesDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
}