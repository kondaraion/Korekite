import SwiftUI
import PhotosUI

struct ClothingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var clothing: ClothingItem
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    @State private var isEditingName = false
    @State private var editedName: String = ""
    @State private var isEditingMemo = false
    @State private var editedMemo: String = ""
    @State private var showingCategoryPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedItem: PhotosPickerItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack(alignment: .bottomTrailing) {
                    clothing.image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding([.bottom, .trailing], 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if isEditingName {
                            TextField("名前", text: $editedName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    clothing.name = editedName
                                    isEditingName = false
                                    storageManager.updateClothingItem(clothing)
                                }
                        } else {
                            Text(clothing.name)
                                .font(.title)
                                .bold()
                        }
                        
                        Button(action: {
                            if isEditingName {
                                clothing.name = editedName
                                storageManager.updateClothingItem(clothing)
                            } else {
                                editedName = clothing.name
                            }
                            isEditingName.toggle()
                        }) {
                            Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle")
                                .foregroundColor(isEditingName ? .green : .blue)
                        }
                    }
                    
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text("カテゴリー: \(clothing.category)")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingCategoryPicker) {
                        NavigationView {
                            List(categoryManager.categories, id: \.self) { category in
                                Button(action: {
                                    clothing.category = category
                                    showingCategoryPicker = false
                                    storageManager.updateClothingItem(clothing)
                                }) {
                                    HStack {
                                        Text(category)
                                        Spacer()
                                        if category == clothing.category {
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("メモ:")
                                .font(.headline)
                            
                            Button(action: {
                                if isEditingMemo {
                                    clothing.memo = editedMemo
                                    storageManager.updateClothingItem(clothing)
                                } else {
                                    editedMemo = clothing.memo
                                }
                                isEditingMemo.toggle()
                            }) {
                                Image(systemName: isEditingMemo ? "checkmark.circle.fill" : "pencil.circle")
                                    .foregroundColor(isEditingMemo ? .green : .blue)
                            }
                        }
                        
                        if isEditingMemo {
                            TextEditor(text: $editedMemo)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        } else {
                            Text(clothing.memo)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("着用履歴")
                            .font(.headline)
                        
                        if clothing.lastWornDates.isEmpty {
                            Text("まだ着用していません")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(clothing.lastWornDates, id: \.self) { date in
                                Text(dateFormatter.string(from: date))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            var updatedClothing = clothing
                            updatedClothing.wearToday()
                            clothing = updatedClothing
                            storageManager.updateClothingItem(clothing)
                        }) {
                            HStack {
                                Image(systemName: "tshirt.fill")
                                Text("今日着る")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showingDeleteConfirmation = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        })
        .alert("削除の確認", isPresented: $showingDeleteConfirmation) {
            Button("削除", role: .destructive) {
                storageManager.deleteClothingItem(clothing)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この服を削除してもよろしいですか？")
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self) {
                    var updatedClothing = clothing
                    updatedClothing.imageData = data
                    clothing = updatedClothing
                    storageManager.updateClothingItem(clothing)
                }
            }
        }
    }
} 