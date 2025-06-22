//
//  KorekiteTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/04/20.
//

import Testing
@testable import Korekite
import Foundation

struct KorekiteTests {

    @Test func testClothingItemInitialization() async throws {
        let item = ClothingItem(name: "テストシャツ", category: "トップス")
        
        #expect(item.name == "テストシャツ")
        #expect(item.category == "トップス")
        #expect(item.memo == "")
        #expect(item.wearHistory.isEmpty)
        #expect(item.imageData == nil)
        #expect(!item.isWornToday)
    }
    
    @Test func testClothingItemWearToday() async throws {
        var item = ClothingItem(name: "テストシャツ", category: "トップス")
        
        #expect(!item.isWornToday)
        
        item.wearToday()
        
        #expect(item.isWornToday)
        #expect(item.wearHistory.count == 1)
        
        item.wearToday()
        
        #expect(item.wearHistory.count == 1)
    }
    
    @Test func testClothingItemUnwearToday() async throws {
        var item = ClothingItem(name: "テストシャツ", category: "トップス")
        
        item.wearToday()
        #expect(item.isWornToday)
        
        item.unwearToday()
        #expect(!item.isWornToday)
        #expect(item.wearHistory.isEmpty)
    }
    
    @Test func testClothingItemLastWornDates() async throws {
        var item = ClothingItem(name: "テストシャツ", category: "トップス")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: today)!
        
        item.wearHistory = [fourDaysAgo, threeDaysAgo, twoDaysAgo, yesterday, today]
        
        let lastWorn = item.lastWornDates
        #expect(lastWorn.count == 3)
        #expect(lastWorn[0] == today)
        #expect(lastWorn[1] == yesterday)
        #expect(lastWorn[2] == twoDaysAgo)
    }
    
    @Test func testClothingItemCoding() async throws {
        let originalItem = ClothingItem(
            name: "テストシャツ",
            category: "トップス",
            memo: "お気に入り",
            wearHistory: [Date()],
            imageData: "test".data(using: .utf8)
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encoded = try encoder.encode(originalItem)
        let decodedItem = try decoder.decode(ClothingItem.self, from: encoded)
        
        #expect(decodedItem.id == originalItem.id)
        #expect(decodedItem.name == originalItem.name)
        #expect(decodedItem.category == originalItem.category)
        #expect(decodedItem.memo == originalItem.memo)
        #expect(decodedItem.imageData == originalItem.imageData)
    }

}
