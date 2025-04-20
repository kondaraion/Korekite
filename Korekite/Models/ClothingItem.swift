import Foundation
import SwiftUI
import UIKit

struct ClothingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var memo: String
    var wearHistory: [Date]
    var imageData: Data?
    
    init(id: UUID = UUID(), name: String, category: String, memo: String = "", wearHistory: [Date] = [], imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.memo = memo
        self.wearHistory = wearHistory
        self.imageData = imageData
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
        if let imageData = imageData,
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "tshirt")
    }
} 