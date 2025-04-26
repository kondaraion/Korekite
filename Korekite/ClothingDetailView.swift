import SwiftUI
import PhotosUI

struct ClothingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var clothing: ClothingItem
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    @State private var isEditingMemo = false
    @State private var editedMemo: String = ""
    @State private var showingCategoryPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var displayedImage: Image?
    @State private var isShowingFullScreenImage = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
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
                    if let displayedImage {
                        displayedImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .onTapGesture {
                                isShowingFullScreenImage = true
                            }
                    } else {
                        clothing.image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .onTapGesture {
                                isShowingFullScreenImage = true
                            }
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 32, height: 32)
                            )
                            .shadow(radius: 2)
                    }
                    .padding([.bottom, .trailing], 12)
                }
                
                VStack(alignment: .leading, spacing: 10) {
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
                            if updatedClothing.isWornToday {
                                updatedClothing.unwearToday()
                            } else {
                                updatedClothing.wearToday()
                            }
                            clothing = updatedClothing
                            storageManager.updateClothingItem(clothing)
                        }) {
                            HStack {
                                Image(systemName: clothing.isWornToday ? "tshirt.fill" : "tshirt")
                                Text(clothing.isWornToday ? "今日の着用を取り消す" : "今日着る")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(clothing.isWornToday ? Color.red : Color.blue)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("一覧へ戻る")
                }
            },
            trailing: Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        )
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
                    await MainActor.run {
                        var updatedClothing = clothing
                        updatedClothing.imageData = data
                        clothing = updatedClothing
                        displayedImage = Image(uiImage: .init(data: data) ?? .init())
                        storageManager.updateClothingItem(clothing)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingFullScreenImage) {
            NavigationView {
                if let displayedImage {
                    displayedImage
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .navigationBarItems(trailing: Button("閉じる") {
                            isShowingFullScreenImage = false
                            scale = 1.0
                            lastScale = 1.0
                        })
                } else {
                    clothing.image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .navigationBarItems(trailing: Button("閉じる") {
                            isShowingFullScreenImage = false
                            scale = 1.0
                            lastScale = 1.0
                        })
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
} 

