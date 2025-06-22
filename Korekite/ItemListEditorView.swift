import SwiftUI

struct ItemListEditorView: View {
    @Binding var itemNames: [String]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var newItemName = ""
    
    var body: some View {
        VStack {
            List {
                Section("アイテム一覧") {
                    ForEach(itemNames.indices, id: \.self) { index in
                        HStack {
                            TextField("アイテム名", text: $itemNames[index])
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
                
                Section("新しいアイテムを追加") {
                    HStack {
                        TextField("アイテム名を入力", text: $newItemName)
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newItemName.isEmpty)
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
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        itemNames.append(newItemName.trimmingCharacters(in: .whitespacesAndNewlines))
        newItemName = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        itemNames.remove(atOffsets: offsets)
    }
}