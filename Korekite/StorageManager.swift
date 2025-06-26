import Foundation
import UIKit

class StorageManager: ObservableObject {
    @Published var outfits: [Outfit] = []
    private let outfitsKey = "outfits"
    private let migrationKey = "imagesMigrated"
    let errorManager = ErrorManager()
    
    // Debouncing用
    private var saveTask: Task<Void, Never>?
    private let saveDelay: TimeInterval = 0.5
    
    init() {
        loadOutfits()
        migrateImagesIfNeeded()
    }
    
    func saveOutfits() {
        debouncedSave()
    }
    
    // Debouncing付きの保存処理（パフォーマンス向上）
    private func debouncedSave() {
        // 前のタスクをキャンセル
        saveTask?.cancel()
        
        // 新しいタスクをスケジュール
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(saveDelay * 1_000_000_000))
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.performSave()
                }
            }
        }
    }
    
    // 即座に保存（重要な操作用）
    func saveOutfitsImmediately() {
        saveTask?.cancel()
        performSave()
    }
    
    // 実際の保存処理
    private func performSave() {
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
        // 初期化時は同期実行、それ以外はメインスレッドで実行
        let executeLoad = {
            guard let data = UserDefaults.standard.data(forKey: self.outfitsKey) else {
                print("No saved outfits data found")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([Outfit].self, from: data)
                self.outfits = decoded
                self.objectWillChange.send()
            } catch {
                print("Error loading outfits: \(error.localizedDescription)")
                // 破損したデータがある場合、空の配列で初期化
                self.outfits = []
                self.errorManager.showError(ErrorInfo(
                    title: "読み込みエラー",
                    message: "保存されたデータが破損しています。新しく作成し直してください。"
                ))
            }
        }
        
        if Thread.isMainThread {
            executeLoad()
        } else {
            DispatchQueue.main.sync {
                executeLoad()
            }
        }
    }
    
    func addOutfit(_ item: Outfit) {
        DispatchQueue.main.async {
            self.outfits.append(item)
            self.saveOutfitsImmediately() // 新規追加は即座に保存
        }
    }
    
    func updateOutfit(_ item: Outfit) {
        DispatchQueue.main.async {
            if let index = self.outfits.firstIndex(where: { $0.id == item.id }) {
                self.outfits[index] = item
                // お気に入り変更は即座に保存（UIの応答性向上）
                self.saveOutfitsImmediately()
            }
        }
    }
    
    // 画像キャッシュ付きでOutfitを取得（パフォーマンス向上）
    func getCachedUIImage(for outfit: Outfit) -> UIImage? {
        // メインスレッドで実行を保証
        if Thread.isMainThread {
            return getCachedUIImageOnMainThread(for: outfit)
        } else {
            return DispatchQueue.main.sync {
                return getCachedUIImageOnMainThread(for: outfit)
            }
        }
    }
    
    private func getCachedUIImageOnMainThread(for outfit: Outfit) -> UIImage? {
        if let index = outfits.firstIndex(where: { $0.id == outfit.id }) {
            var mutableOutfit = outfits[index]
            let image = mutableOutfit.getCachedUIImage()
            outfits[index] = mutableOutfit
            return image
        }
        return nil
    }
    
    // 画像更新時にキャッシュをクリア
    func clearImageCache(for outfitId: UUID) {
        // メインスレッドで実行を保証
        if Thread.isMainThread {
            clearImageCacheOnMainThread(for: outfitId)
        } else {
            DispatchQueue.main.async {
                self.clearImageCacheOnMainThread(for: outfitId)
            }
        }
    }
    
    private func clearImageCacheOnMainThread(for outfitId: UUID) {
        if let index = outfits.firstIndex(where: { $0.id == outfitId }) {
            var mutableOutfit = outfits[index]
            mutableOutfit.clearImageCache()
            outfits[index] = mutableOutfit
        }
    }
    
    func deleteOutfit(_ item: Outfit) {
        DispatchQueue.main.async {
            // 画像ファイルも削除
            if let filename = item.imageFilename {
                ImageStorageManager.shared.deleteImage(filename: filename)
            }
            
            self.outfits.removeAll { $0.id == item.id }
            self.saveOutfitsImmediately() // 削除は即座に保存
        }
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