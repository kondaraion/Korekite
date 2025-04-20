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
    @State private var selectedCategory: String?
    @State private var showingAddClothing = false
    
    var filteredItems: [ClothingItem] {
        if let category = selectedCategory {
            return storageManager.clothingItems.filter { $0.category == category }
        }
        return storageManager.clothingItems
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "すべて", isSelected: selectedCategory == nil) {
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
                    LazyVStack(spacing: 16) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: ClothingDetailView(clothing: binding(for: item), categoryManager: categoryManager, storageManager: storageManager)) {
                                HStack(spacing: 16) {
                                    item.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        Text(item.category)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        if !item.memo.isEmpty {
                                            Text(item.memo)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("クローゼット")
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
            get: { item },
            set: { newValue in
                storageManager.updateClothingItem(newValue)
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

