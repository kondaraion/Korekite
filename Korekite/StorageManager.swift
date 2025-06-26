import Foundation
import UIKit

class StorageManager: ObservableObject {
    @Published var outfits: [Outfit] = []
    private let outfitsKey = "outfits"
    private let migrationKey = "imagesMigrated"
    let errorManager = ErrorManager()
    
    init() {
        loadOutfits()
        migrateImagesIfNeeded()
    }
    
    func saveOutfits() {
        do {
            let encoded = try JSONEncoder().encode(outfits)
            UserDefaults.standard.set(encoded, forKey: outfitsKey)
            objectWillChange.send()
        } catch {
            print("Error saving outfits: \(error.localizedDescription)")
            errorManager.showError(ErrorInfo(
                title: "保存エラー",
                message: "データの保存に失敗しました。アプリを再起動してもう一度お試しください。"
            ))
        }
    }
    
    func loadOutfits() {
        guard let data = UserDefaults.standard.data(forKey: outfitsKey) else {
            print("No saved outfits data found")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Outfit].self, from: data)
            outfits = decoded
            objectWillChange.send()
        } catch {
            print("Error loading outfits: \(error.localizedDescription)")
            // 破損したデータがある場合、空の配列で初期化
            outfits = []
            errorManager.showError(ErrorInfo(
                title: "読み込みエラー",
                message: "保存されたデータが破損しています。新しく作成し直してください。"
            ))
        }
    }
    
    func addOutfit(_ item: Outfit) {
        outfits.append(item)
        saveOutfits()
    }
    
    func updateOutfit(_ item: Outfit) {
        if let index = outfits.firstIndex(where: { $0.id == item.id }) {
            outfits[index] = item
            saveOutfits()
        }
    }
    
    func deleteOutfit(_ item: Outfit) {
        // 画像ファイルも削除
        if let filename = item.imageFilename {
            ImageStorageManager.shared.deleteImage(filename: filename)
        }
        
        outfits.removeAll { $0.id == item.id }
        saveOutfits()
    }
    
    func saveImage(_ imageData: Data, for outfitId: UUID) -> String? {
        guard let uiImage = UIImage(data: imageData),
              let compressedData = ImageUtils.processForStorage(uiImage) else {
            return nil
        }
        return ImageStorageManager.shared.saveImage(compressedData, for: outfitId)
    }
    
    // MARK: - Migration
    
    private func migrateImagesIfNeeded() {
        let hasMigrated = UserDefaults.standard.bool(forKey: migrationKey)
        if !hasMigrated && !outfits.isEmpty {
            print("Starting image migration...")
            outfits = ImageStorageManager.shared.migrateFromUserDefaults(outfits: outfits)
            saveOutfits()
            UserDefaults.standard.set(true, forKey: migrationKey)
            print("Image migration completed")
        }
    }
} 