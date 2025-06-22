//
//  StorageManagerTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/06/22.
//

import Testing
@testable import Korekite
import Foundation

struct StorageManagerTests {
    
    @Test func testStorageManagerInitialization() async throws {
        let storageManager = StorageManager()
        
        #expect(storageManager.clothingItems.isEmpty)
    }
    
    @Test func testAddClothingItem() async throws {
        let storageManager = StorageManager()
        let item = ClothingItem(name: "テストシャツ", category: "トップス")
        
        storageManager.addClothingItem(item)
        
        #expect(storageManager.clothingItems.count == 1)
        #expect(storageManager.clothingItems.first?.name == "テストシャツ")
        #expect(storageManager.clothingItems.first?.category == "トップス")
    }
    
    @Test func testUpdateClothingItem() async throws {
        let storageManager = StorageManager()
        let originalItem = ClothingItem(name: "テストシャツ", category: "トップス")
        
        storageManager.addClothingItem(originalItem)
        
        var updatedItem = originalItem
        updatedItem.name = "更新されたシャツ"
        updatedItem.memo = "メモ追加"
        
        storageManager.updateClothingItem(updatedItem)
        
        #expect(storageManager.clothingItems.count == 1)
        #expect(storageManager.clothingItems.first?.name == "更新されたシャツ")
        #expect(storageManager.clothingItems.first?.memo == "メモ追加")
        #expect(storageManager.clothingItems.first?.id == originalItem.id)
    }
    
    @Test func testDeleteClothingItem() async throws {
        let storageManager = StorageManager()
        let item1 = ClothingItem(name: "シャツ1", category: "トップス")
        let item2 = ClothingItem(name: "シャツ2", category: "トップス")
        
        storageManager.addClothingItem(item1)
        storageManager.addClothingItem(item2)
        
        #expect(storageManager.clothingItems.count == 2)
        
        storageManager.deleteClothingItem(item1)
        
        #expect(storageManager.clothingItems.count == 1)
        #expect(storageManager.clothingItems.first?.name == "シャツ2")
    }
    
    @Test func testUpdateNonExistentItem() async throws {
        let storageManager = StorageManager()
        let item1 = ClothingItem(name: "シャツ1", category: "トップス")
        let item2 = ClothingItem(name: "シャツ2", category: "トップス")
        
        storageManager.addClothingItem(item1)
        
        storageManager.updateClothingItem(item2)
        
        #expect(storageManager.clothingItems.count == 1)
        #expect(storageManager.clothingItems.first?.name == "シャツ1")
    }
    
    @Test func testDeleteNonExistentItem() async throws {
        let storageManager = StorageManager()
        let item1 = ClothingItem(name: "シャツ1", category: "トップス")
        let item2 = ClothingItem(name: "シャツ2", category: "トップス")
        
        storageManager.addClothingItem(item1)
        
        storageManager.deleteClothingItem(item2)
        
        #expect(storageManager.clothingItems.count == 1)
        #expect(storageManager.clothingItems.first?.name == "シャツ1")
    }
    
    @Test func testMultipleOperations() async throws {
        let storageManager = StorageManager()
        
        let item1 = ClothingItem(name: "シャツ", category: "トップス")
        let item2 = ClothingItem(name: "パンツ", category: "ボトムス")
        let item3 = ClothingItem(name: "ジャケット", category: "アウター")
        
        storageManager.addClothingItem(item1)
        storageManager.addClothingItem(item2)
        storageManager.addClothingItem(item3)
        
        #expect(storageManager.clothingItems.count == 3)
        
        var updatedItem1 = item1
        updatedItem1.name = "更新されたシャツ"
        storageManager.updateClothingItem(updatedItem1)
        
        storageManager.deleteClothingItem(item2)
        
        #expect(storageManager.clothingItems.count == 2)
        
        let shirts = storageManager.clothingItems.filter { $0.name.contains("シャツ") }
        #expect(shirts.count == 1)
        #expect(shirts.first?.name == "更新されたシャツ")
        
        let jackets = storageManager.clothingItems.filter { $0.category == "アウター" }
        #expect(jackets.count == 1)
        #expect(jackets.first?.name == "ジャケット")
    }
}