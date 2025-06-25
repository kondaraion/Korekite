//
//  ItemNameManagerTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/06/24.
//

import Testing
@testable import Korekite
import Foundation

struct ItemNameManagerTests {
    
    @Test func testItemNameManagerInitialization() async throws {
        let manager = ItemNameManager()
        
        #expect(manager.recentItemNames.isEmpty)
        #expect(manager.allItemNames.isEmpty)
    }
    
    @Test func testAddItemName() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("テストシャツ")
        
        #expect(manager.recentItemNames.contains("テストシャツ"))
        #expect(manager.allItemNames.contains("テストシャツ"))
        #expect(manager.recentItemNames.count == 1)
        #expect(manager.allItemNames.count == 1)
    }
    
    @Test func testAddDuplicateItemName() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("テストシャツ")
        manager.addItemName("テストシャツ")
        
        #expect(manager.recentItemNames.count == 1)
        #expect(manager.allItemNames.count == 1)
        #expect(manager.recentItemNames.first == "テストシャツ")
    }
    
    @Test func testAddEmptyItemName() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("")
        
        #expect(manager.recentItemNames.isEmpty)
        #expect(manager.allItemNames.isEmpty)
    }
    
    @Test func testAddWhitespaceItemName() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("   ")
        
        #expect(manager.recentItemNames.isEmpty)
        #expect(manager.allItemNames.isEmpty)
    }
    
    @Test func testRecentItemNamesLimit() async throws {
        let manager = ItemNameManager()
        
        for i in 1...15 {
            manager.addItemName("アイテム\(i)")
        }
        
        #expect(manager.recentItemNames.count == 10)
        #expect(manager.allItemNames.count == 15)
        #expect(manager.recentItemNames.first == "アイテム15")
        #expect(manager.recentItemNames.last == "アイテム6")
        #expect(!manager.recentItemNames.contains("アイテム1"))
        #expect(manager.allItemNames.contains("アイテム1"))
    }
    
    @Test func testRecentItemNamesOrder() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("シャツ")
        manager.addItemName("パンツ")
        manager.addItemName("ジャケット")
        
        #expect(manager.recentItemNames[0] == "ジャケット")
        #expect(manager.recentItemNames[1] == "パンツ")
        #expect(manager.recentItemNames[2] == "シャツ")
        
        manager.addItemName("シャツ")
        
        #expect(manager.recentItemNames[0] == "シャツ")
        #expect(manager.recentItemNames[1] == "ジャケット")
        #expect(manager.recentItemNames[2] == "パンツ")
    }
    
    @Test func testSearchItemNames() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("白いシャツ")
        manager.addItemName("黒いシャツ")
        manager.addItemName("青いパンツ")
        manager.addItemName("白いパンツ")
        manager.addItemName("赤いジャケット")
        
        let shirtResults = manager.searchItemNames("シャツ")
        #expect(shirtResults.count == 2)
        #expect(shirtResults.contains("白いシャツ"))
        #expect(shirtResults.contains("黒いシャツ"))
        
        let whiteResults = manager.searchItemNames("白い")
        #expect(whiteResults.count == 2)
        #expect(whiteResults.contains("白いシャツ"))
        #expect(whiteResults.contains("白いパンツ"))
        
        let emptyResults = manager.searchItemNames("")
        #expect(emptyResults.isEmpty)
        
        let noMatchResults = manager.searchItemNames("存在しない")
        #expect(noMatchResults.isEmpty)
    }
    
    @Test func testSearchItemNamesCaseInsensitive() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("Tシャツ")
        manager.addItemName("tシャツ")
        
        let results = manager.searchItemNames("t")
        #expect(results.count == 2)
        #expect(results.contains("Tシャツ"))
        #expect(results.contains("tシャツ"))
        
        let upperResults = manager.searchItemNames("T")
        #expect(upperResults.count == 2)
    }
    
    @Test func testFrequentItemNames() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("アイテム1")
        manager.addItemName("アイテム2")
        manager.addItemName("アイテム1")
        
        #expect(manager.frequentItemNames.count >= 2)
        let topItem = manager.frequentItemNames.first
        #expect(topItem?.name == "アイテム1")
        #expect(topItem?.count == 2)
    }
    
    @Test func testRecommendedItemNames() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("人気アイテム")
        manager.addItemName("人気アイテム")
        manager.addItemName("普通アイテム")
        
        let recommended = manager.getRecommendedItemNames()
        #expect(recommended.contains("人気アイテム"))
        #expect(recommended.count <= 5)
    }
    
    @Test func testInitializeFromExistingData() async throws {
        let existingOutfits = [
            Outfit(name: "", category: "トップス", memo: "", wearHistory: [], imageData: nil, itemNames: ["既存シャツ1", "既存シャツ2"]),
            Outfit(name: "", category: "ボトムス", memo: "", wearHistory: [], imageData: nil, itemNames: ["既存パンツ"]),
            Outfit(name: "", category: "アウター", memo: "", wearHistory: [], imageData: nil, itemNames: ["既存ジャケット", "既存シャツ1"])
        ]
        
        let manager = ItemNameManager()
        manager.initializeFromExistingData(existingOutfits)
        
        #expect(manager.allItemNames.contains("既存シャツ1"))
        #expect(manager.allItemNames.contains("既存シャツ2"))
        #expect(manager.allItemNames.contains("既存パンツ"))
        #expect(manager.allItemNames.contains("既存ジャケット"))
        
        let shirtItem = manager.frequentItemNames.first { $0.name == "既存シャツ1" }
        #expect(shirtItem?.count == 2)
        
        let shirtItem2 = manager.frequentItemNames.first { $0.name == "既存シャツ2" }
        #expect(shirtItem2?.count == 1)
    }
    
    @Test func testComplexScenario() async throws {
        let manager = ItemNameManager()
        
        manager.addItemName("白Tシャツ")
        manager.addItemName("黒Tシャツ")
        manager.addItemName("デニムパンツ")
        
        manager.addItemName("白Tシャツ")
        manager.addItemName("白Tシャツ")
        
        let searchResults = manager.searchItemNames("T")
        #expect(searchResults.count == 2)
        
        manager.addItemName("白Tシャツ")
        
        #expect(manager.recentItemNames.first == "白Tシャツ")
        
        let whiteShirtItem = manager.frequentItemNames.first { $0.name == "白Tシャツ" }
        #expect(whiteShirtItem?.count == 4)
        
        for i in 1...10 {
            manager.addItemName("新しいアイテム\(i)")
        }
        
        #expect(manager.recentItemNames.count == 10)
        #expect(!manager.recentItemNames.contains("黒Tシャツ"))
        #expect(manager.allItemNames.contains("黒Tシャツ"))
    }
}