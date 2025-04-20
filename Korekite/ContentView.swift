//
//  ContentView.swift
//  Korekite
//
//  Created by 国米宏司 on 2025/04/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var categoryManager = CategoryManager()
    @StateObject private var storageManager = StorageManager()
    @AppStorage("selectedCategory") private var selectedCategory: String?
    @State private var showingAddClothing = false
    
    // 2列のグリッドレイアウト
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var filteredItems: [ClothingItem] {
        if let category = selectedCategory, !category.isEmpty {
            return storageManager.clothingItems.filter { $0.category == category }
        }
        return storageManager.clothingItems
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "すべて", isSelected: selectedCategory == nil || selectedCategory?.isEmpty == true) {
                            selectedCategory = nil
                        }
                        
                        ForEach(categoryManager.categories, id: \.self) { category in
                            CategoryButton(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: ClothingDetailView(clothing: binding(for: item), categoryManager: categoryManager, storageManager: storageManager)) {
                                item.image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: UIScreen.main.bounds.width / 2) // 画面幅の半分のサイズに設定
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("今日はこれ着る？")
            .navigationBarItems(trailing: Button(action: {
                showingAddClothing = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddClothing) {
                AddClothingView(categoryManager: categoryManager, storageManager: storageManager)
            }
        }
    }
    
    private func binding(for item: ClothingItem) -> Binding<ClothingItem> {
        Binding(
            get: {
                if let index = storageManager.clothingItems.firstIndex(where: { $0.id == item.id }) {
                    return storageManager.clothingItems[index]
                }
                return item
            },
            set: { newValue in
                if let index = storageManager.clothingItems.firstIndex(where: { $0.id == newValue.id }) {
                    storageManager.clothingItems[index] = newValue
                    storageManager.saveClothingItems()
                }
            }
        )
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    ContentView()
}

