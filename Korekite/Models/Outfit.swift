import Foundation
import SwiftUI
import UIKit

struct Outfit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var memo: String
    var wearHistory: [Date]
    var imageData: Data? // 後方互換性のために残す（マイグレーション用）
    var imageFilename: String? // 新しい画像ファイル参照
    var itemNames: [String]
    var isFavorite: Bool
    var isReferenceImage: Bool
    
    // パフォーマンス向上のための画像キャッシュ（エンコード対象外）
    private var _cachedUIImage: UIImage?
    private var _cacheKey: String?
    
    init(id: UUID = UUID(), name: String, category: String, memo: String = "", wearHistory: [Date] = [], imageData: Data? = nil, imageFilename: String? = nil, itemNames: [String] = [], isFavorite: Bool = false, isReferenceImage: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.memo = memo
        self.wearHistory = wearHistory
        self.imageData = imageData
        self.imageFilename = imageFilename
        self.itemNames = itemNames
        self.isFavorite = isFavorite
        self.isReferenceImage = isReferenceImage
        
        // キャッシュは初期化時にnilに設定
        self._cachedUIImage = nil
        self._cacheKey = nil
    }
    
    var lastWornDates: [Date] {
        wearHistory.sorted(by: >).prefix(3).map { $0 }
    }
    
    var isWornToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return wearHistory.contains { Calendar.current.isDate($0, inSameDayAs: today) }
    }
    
    mutating func wearToday() {
        let today = Calendar.current.startOfDay(for: Date())
        if !wearHistory.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            wearHistory.append(today)
        }
    }
    
    mutating func unwearToday() {
        let today = Calendar.current.startOfDay(for: Date())
        wearHistory.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
    }
    
    var image: Image {
        // キャッシュが有効な場合はそれを使用
        let currentCacheKey = imageFilename ?? "legacy_\(id.uuidString)"
        if let cachedImage = _cachedUIImage, _cacheKey == currentCacheKey {
            return Image(uiImage: cachedImage)
        }
        
        // キャッシュが無効な場合は直接読み込み（キャッシュ更新はStorageManager側で行う）
        if let loadedImage = loadUIImage() {
            return Image(uiImage: loadedImage)
        }
        
        return Image(systemName: "tshirt")
    }
    
    // キャッシュされたUIImageを取得（パフォーマンス向上）
    mutating func getCachedUIImage() -> UIImage? {
        let currentCacheKey = imageFilename ?? "legacy_\(id.uuidString)"
        
        // キャッシュが有効な場合は返す
        if let cachedImage = _cachedUIImage, _cacheKey == currentCacheKey {
            return cachedImage
        }
        
        // キャッシュが無効な場合は新しく読み込み
        let loadedImage = loadUIImage()
        _cachedUIImage = loadedImage
        _cacheKey = currentCacheKey
        
        return loadedImage
    }
    
    // UIImageを読み込む（プライベート）
    private func loadUIImage() -> UIImage? {
        // 新しい方式：ファイル名から画像を読み込み
        if let filename = imageFilename,
           let imageData = ImageStorageManager.shared.loadImage(filename: filename),
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        
        // 後方互換性：従来のimageDataから読み込み
        if let imageData = imageData,
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        
        return nil
    }
    
    // キャッシュをクリア（画像更新時に使用）
    mutating func clearImageCache() {
        _cachedUIImage = nil
        _cacheKey = nil
    }
    
    var hasImage: Bool {
        return imageFilename != nil || imageData != nil
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, memo, wearHistory, imageData, imageFilename, itemNames, isFavorite, isReferenceImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        memo = try container.decode(String.self, forKey: .memo)
        wearHistory = try container.decode([Date].self, forKey: .wearHistory)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        imageFilename = try container.decodeIfPresent(String.self, forKey: .imageFilename)
        itemNames = try container.decode([String].self, forKey: .itemNames)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        isReferenceImage = try container.decodeIfPresent(Bool.self, forKey: .isReferenceImage) ?? false
        
        // キャッシュは初期化時にnilに設定
        _cachedUIImage = nil
        _cacheKey = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(memo, forKey: .memo)
        try container.encode(wearHistory, forKey: .wearHistory)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(imageFilename, forKey: .imageFilename)
        try container.encode(itemNames, forKey: .itemNames)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isReferenceImage, forKey: .isReferenceImage)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Outfit, rhs: Outfit) -> Bool {
        return lhs.id == rhs.id
    }
} 