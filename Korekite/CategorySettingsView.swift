import SwiftUI

struct CategorySettingsView: View {
    @ObservedObject var categoryManager: CategoryManager
    @State private var newCategory: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("カテゴリー追加")) {
                    HStack {
                        TextField("新しいカテゴリー", text: $newCategory)
                        Button(action: {
                            if !newCategory.isEmpty {
                                categoryManager.addCategory(newCategory)
                                newCategory = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("カテゴリー一覧")) {
                    ForEach(categoryManager.categories, id: \.self) { category in
                        Text(category)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            categoryManager.removeCategory(categoryManager.categories[index])
                        }
                    }
                    .onMove { source, destination in
                        var categories = categoryManager.categories
                        categories.move(fromOffsets: source, toOffset: destination)
                        categoryManager.categories = categories
                    }
                }
            }
            .navigationTitle("カテゴリー設定")
            .navigationBarItems(
                trailing: EditButton()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
} 