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
    
    init(id: UUID = UUID(), name: String, category: String, memo: String = "", wearHistory: [Date] = [], imageData: Data? = nil, imageFilename: String? = nil, itemNames: [String] = [], isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.memo = memo
        self.wearHistory = wearHistory
        self.imageData = imageData
        self.imageFilename = imageFilename
        self.itemNames = itemNames
        self.isFavorite = isFavorite
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
        // 新しい方式：ファイル名から画像を読み込み
        if let filename = imageFilename,
           let imageData = ImageStorageManager.shared.loadImage(filename: filename),
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        
        // 後方互換性：従来のimageDataから読み込み
        if let imageData = imageData,
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        
        return Image(systemName: "tshirt")
    }
    
    var hasImage: Bool {
        return imageFilename != nil || imageData != nil
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Outfit, rhs: Outfit) -> Bool {
        return lhs.id == rhs.id
    }
} 