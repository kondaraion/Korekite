//
//  CategoryManagerTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/06/24.
//

import Testing
@testable import Korekite
import Foundation

struct CategoryManagerTests {
    
    @Test func testCategoryManagerInitialization() async throws {
        let categoryManager = CategoryManager()
        
        #expect(categoryManager.categories.count == 6)
        #expect(categoryManager.categories.contains("極寒"))
        #expect(categoryManager.categories.contains("寒い"))
        #expect(categoryManager.categories.contains("涼しい"))
        #expect(categoryManager.categories.contains("暖かい"))
        #expect(categoryManager.categories.contains("暑い"))
        #expect(categoryManager.categories.contains("猛暑"))
    }
    
    @Test func testAddCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.addCategory("新しいカテゴリ")
        
        #expect(categoryManager.categories.count == initialCount + 1)
        #expect(categoryManager.categories.contains("新しいカテゴリ"))
    }
    
    @Test func testAddDuplicateCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.addCategory("極寒")
        
        #expect(categoryManager.categories.count == initialCount)
        #expect(categoryManager.categories.filter { $0 == "極寒" }.count == 1)
    }
    
    @Test func testAddEmptyCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.addCategory("")
        
        #expect(categoryManager.categories.count == initialCount + 1)
        #expect(categoryManager.categories.contains(""))
    }
    
    @Test func testAddWhitespaceCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.addCategory("   ")
        
        #expect(categoryManager.categories.count == initialCount + 1)
        #expect(categoryManager.categories.contains("   "))
    }
    
    @Test func testRemoveCategory() async throws {
        let categoryManager = CategoryManager()
        categoryManager.addCategory("削除テスト")
        
        let countAfterAdd = categoryManager.categories.count
        #expect(categoryManager.categories.contains("削除テスト"))
        
        categoryManager.removeCategory("削除テスト")
        
        #expect(categoryManager.categories.count == countAfterAdd - 1)
        #expect(!categoryManager.categories.contains("削除テスト"))
    }
    
    @Test func testRemoveNonExistentCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.removeCategory("存在しないカテゴリ")
        
        #expect(categoryManager.categories.count == initialCount)
    }
    
    @Test func testRemoveDefaultCategory() async throws {
        let categoryManager = CategoryManager()
        let initialCount = categoryManager.categories.count
        
        categoryManager.removeCategory("極寒")
        
        #expect(categoryManager.categories.count == initialCount - 1)
        #expect(!categoryManager.categories.contains("極寒"))
    }
    
    @Test func testMoveCategory() async throws {
        let categoryManager = CategoryManager()
        categoryManager.addCategory("移動テスト1")
        categoryManager.addCategory("移動テスト2")
        
        let initialCategories = categoryManager.categories
        let sourceIndex = categoryManager.categories.firstIndex(of: "移動テスト1")!
        let targetIndex = categoryManager.categories.firstIndex(of: "移動テスト2")!
        
        categoryManager.moveCategory(from: IndexSet([sourceIndex]), to: targetIndex)
        
        #expect(categoryManager.categories != initialCategories)
    }
    
    @Test func testMoveCategoryWithMultipleIndices() async throws {
        let categoryManager = CategoryManager()
        categoryManager.addCategory("テスト1")
        categoryManager.addCategory("テスト2")
        categoryManager.addCategory("テスト3")
        
        let initialCount = categoryManager.categories.count
        let sourceIndices = IndexSet([0, 2])
        
        categoryManager.moveCategory(from: sourceIndices, to: 1)
        
        #expect(categoryManager.categories.count == initialCount)
    }
    
    @Test func testMultipleCategoryOperations() async throws {
        let categoryManager = CategoryManager()
        
        categoryManager.addCategory("テスト1")
        categoryManager.addCategory("テスト2")
        categoryManager.addCategory("テスト3")
        
        #expect(categoryManager.categories.contains("テスト1"))
        #expect(categoryManager.categories.contains("テスト2"))
        #expect(categoryManager.categories.contains("テスト3"))
        
        categoryManager.removeCategory("テスト2")
        
        #expect(categoryManager.categories.contains("テスト1"))
        #expect(!categoryManager.categories.contains("テスト2"))
        #expect(categoryManager.categories.contains("テスト3"))
        
        let index1 = categoryManager.categories.firstIndex(of: "テスト1")!
        let index3 = categoryManager.categories.firstIndex(of: "テスト3")!
        
        categoryManager.moveCategory(from: IndexSet([index1]), to: index3)
        
        #expect(categoryManager.categories.contains("テスト1"))
        #expect(categoryManager.categories.contains("テスト3"))
    }
}