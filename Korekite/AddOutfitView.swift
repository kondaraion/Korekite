import SwiftUI
import PhotosUI

struct AddOutfitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    
    @State private var selectedCategory: String = ""
    @State private var memo: String = ""
    @State private var showingCategoryPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("写真")) {
                    HStack {
                        Spacer()
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .cornerRadius(10)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Label("写真を選択", systemImage: "photo.on.rectangle")
                    }
                }
                
                Section(header: Text("基本情報")) {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text("カテゴリー")
                            Spacer()
                            Text(selectedCategory.isEmpty ? "選択してください" : selectedCategory)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("メモ")) {
                    TextEditor(text: $memo)
                        .frame(height: 100)
                }
            }
            .navigationTitle("新規服の追加")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("追加") {
                    addClothing()
                }
                .disabled(selectedCategory.isEmpty || selectedImageData == nil)
            )
            .sheet(isPresented: $showingCategoryPicker) {
                NavigationView {
                    List(categoryManager.categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            showingCategoryPicker = false
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if category == selectedCategory {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .navigationTitle("カテゴリー選択")
                    .navigationBarItems(trailing: Button("キャンセル") {
                        showingCategoryPicker = false
                    })
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let item = newValue,
                       let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func addClothing() {
        let newItem = Outfit(
            name: UUID().uuidString, // 一意のIDを名前として使用
            category: selectedCategory,
            memo: memo,
            imageData: selectedImageData
        )
        storageManager.addOutfit(newItem)
        dismiss()
    }
} 