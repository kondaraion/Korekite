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
        
        #expect(storageManager.outfits.isEmpty)
    }
    
    @Test func testAddOutfit() async throws {
        let storageManager = StorageManager()
        let item = Outfit(name: "テストシャツ", category: "トップス")
        
        storageManager.addOutfit(item)
        
        #expect(storageManager.outfits.count == 1)
        #expect(storageManager.outfits.first?.name == "テストシャツ")
        #expect(storageManager.outfits.first?.category == "トップス")
    }
    
    @Test func testUpdateOutfit() async throws {
        let storageManager = StorageManager()
        let originalItem = Outfit(name: "テストシャツ", category: "トップス")
        
        storageManager.addOutfit(originalItem)
        
        var updatedItem = originalItem
        updatedItem.name = "更新されたシャツ"
        updatedItem.memo = "メモ追加"
        
        storageManager.updateOutfit(updatedItem)
        
        #expect(storageManager.outfits.count == 1)
        #expect(storageManager.outfits.first?.name == "更新されたシャツ")
        #expect(storageManager.outfits.first?.memo == "メモ追加")
        #expect(storageManager.outfits.first?.id == originalItem.id)
    }
    
    @Test func testDeleteOutfit() async throws {
        let storageManager = StorageManager()
        let item1 = Outfit(name: "シャツ1", category: "トップス")
        let item2 = Outfit(name: "シャツ2", category: "トップス")
        
        storageManager.addOutfit(item1)
        storageManager.addOutfit(item2)
        
        #expect(storageManager.outfits.count == 2)
        
        storageManager.deleteOutfit(item1)
        
        #expect(storageManager.outfits.count == 1)
        #expect(storageManager.outfits.first?.name == "シャツ2")
    }
    
    @Test func testUpdateNonExistentItem() async throws {
        let storageManager = StorageManager()
        let item1 = Outfit(name: "シャツ1", category: "トップス")
        let item2 = Outfit(name: "シャツ2", category: "トップス")
        
        storageManager.addOutfit(item1)
        
        storageManager.updateOutfit(item2)
        
        #expect(storageManager.outfits.count == 1)
        #expect(storageManager.outfits.first?.name == "シャツ1")
    }
    
    @Test func testDeleteNonExistentItem() async throws {
        let storageManager = StorageManager()
        let item1 = Outfit(name: "シャツ1", category: "トップス")
        let item2 = Outfit(name: "シャツ2", category: "トップス")
        
        storageManager.addOutfit(item1)
        
        storageManager.deleteOutfit(item2)
        
        #expect(storageManager.outfits.count == 1)
        #expect(storageManager.outfits.first?.name == "シャツ1")
    }
    
    @Test func testMultipleOperations() async throws {
        let storageManager = StorageManager()
        
        let item1 = Outfit(name: "シャツ", category: "トップス")
        let item2 = Outfit(name: "パンツ", category: "ボトムス")
        let item3 = Outfit(name: "ジャケット", category: "アウター")
        
        storageManager.addOutfit(item1)
        storageManager.addOutfit(item2)
        storageManager.addOutfit(item3)
        
        #expect(storageManager.outfits.count == 3)
        
        var updatedItem1 = item1
        updatedItem1.name = "更新されたシャツ"
        storageManager.updateOutfit(updatedItem1)
        
        storageManager.deleteOutfit(item2)
        
        #expect(storageManager.outfits.count == 2)
        
        let shirts = storageManager.outfits.filter { $0.name.contains("シャツ") }
        #expect(shirts.count == 1)
        #expect(shirts.first?.name == "更新されたシャツ")
        
        let jackets = storageManager.outfits.filter { $0.category == "アウター" }
        #expect(jackets.count == 1)
        #expect(jackets.first?.name == "ジャケット")
    }
}