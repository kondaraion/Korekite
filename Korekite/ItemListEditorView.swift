import SwiftUI

struct ItemListEditorView: View {
    @Binding var itemNames: [String]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var newItemName = ""
    @ObservedObject var itemNameManager: ItemNameManager
    @State private var searchQuery = ""
    @State private var showingAllSuggestions = false
    
    // 検索結果に基づく候補
    var filteredSuggestions: [String] {
        if searchQuery.isEmpty {
            return Array(itemNameManager.recentItemNames.prefix(5))
        } else {
            return itemNameManager.searchItemNames(searchQuery)
        }
    }
    
    // 頻度の高いアイテム候補
    var topSuggestions: [String] {
        itemNameManager.getRecommendedItemNames()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                // 現在のアイテム一覧
                Section("現在のアイテム") {
                    ForEach(itemNames.indices, id: \.self) { index in
                        HStack {
                            TextField("アイテム名", text: $itemNames[index])
                                .font(.body)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                itemNames.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                
                // 候補選択セクション
                if !filteredSuggestions.isEmpty {
                    Section(header: HStack {
                        Text(searchQuery.isEmpty ? "最近使用したアイテム" : "検索結果")
                        Spacer()
                        if !searchQuery.isEmpty && filteredSuggestions.count > 5 {
                            Button(showingAllSuggestions ? "折りたたむ" : "すべて表示") {
                                showingAllSuggestions.toggle()
                            }
                            .font(.footnote)
                            .foregroundColor(.blue)
                        }
                    }) {
                        let displayedSuggestions = showingAllSuggestions ? filteredSuggestions : Array(filteredSuggestions.prefix(5))
                        
                        ForEach(displayedSuggestions, id: \.self) { suggestion in
                            if !itemNames.contains(suggestion) {
                                Button(action: {
                                    itemNames.append(suggestion)
                                    itemNameManager.addItemName(suggestion)
                                    searchQuery = ""
                                    showingAllSuggestions = false
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.green)
                                        Text(suggestion)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        
                                        // 頻度表示
                                        if let frequency = itemNameManager.frequentItemNames.first(where: { $0.name == suggestion })?.count {
                                            Text("\(frequency)回")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                // 手動入力セクション
                Section("新しいアイテムを追加") {
                    VStack(spacing: 12) {
                        // 検索・入力フィールド
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("アイテム名を検索または入力", text: $searchQuery)
                                .font(.body)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    if !searchQuery.isEmpty && !itemNames.contains(searchQuery) {
                                        addItemWithName(searchQuery)
                                    }
                                }
                        }
                        
                        // 手動入力エリア
                        HStack {
                            TextField("新しいアイテム名", text: $newItemName)
                                .font(.body)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: addItem) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .disabled(newItemName.isEmpty)
                        }
                    }
                }
                
                // よく使用されるアイテム
                if !topSuggestions.isEmpty && searchQuery.isEmpty {
                    Section("よく使用されるアイテム") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(topSuggestions, id: \.self) { suggestion in
                                    if !itemNames.contains(suggestion) {
                                        Button(action: {
                                            itemNames.append(suggestion)
                                            itemNameManager.addItemName(suggestion)
                                        }) {
                                            Text(suggestion)
                                                .font(.subheadline)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("アイテム編集")
        .navigationBarItems(
            leading: Button("キャンセル") {
                dismiss()
            },
            trailing: Button("保存") {
                onSave()
            }
        )
    }
    
    private func addItem() {
        addItemWithName(newItemName)
        newItemName = ""
    }
    
    private func addItemWithName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty && !itemNames.contains(trimmedName) else { return }
        
        itemNames.append(trimmedName)
        itemNameManager.addItemName(trimmedName)
        searchQuery = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        itemNames.remove(atOffsets: offsets)
    }
}