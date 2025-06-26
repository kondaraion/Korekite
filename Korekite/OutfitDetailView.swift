import SwiftUI
import PhotosUI

struct OutfitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var outfit: Outfit
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var itemNameManager: ItemNameManager
    @State private var isEditingName = false
    @State private var editedName: String = ""
    @State private var isEditingMemo = false
    @State private var editedMemo: String = ""
    @State private var showingCategoryPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var displayedImage: Image?
    @State private var isShowingFullScreenImage = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showingItemEditor = false
    @State private var editedItemNames: [String] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                imageSection
                nameSection
                categorySection
                memoSection
                itemsSection
                wearHistorySection
                favoriteSection
            }
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(backgroundGradient)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: trailingButtons)
        .alert("削除の確認", isPresented: $showingDeleteConfirmation) {
            Button("削除", role: .destructive) {
                storageManager.deleteOutfit(outfit)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この服を削除してもよろしいですか？")
        }
        .sheet(isPresented: $showingItemEditor) {
            NavigationView {
                ItemListEditorView(itemNames: $editedItemNames, onSave: {
                    outfit.itemNames = editedItemNames
                    storageManager.updateOutfit(outfit)
                    showingItemEditor = false
                }, itemNameManager: itemNameManager)
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        var updatedOutfit = outfit
                        
                        // 古い画像ファイルを削除
                        if let oldFilename = updatedOutfit.imageFilename {
                            ImageStorageManager.shared.deleteImage(filename: oldFilename)
                        }
                        
                        // 新しい画像を保存
                        if let filename = storageManager.saveImage(data, for: updatedOutfit.id) {
                            updatedOutfit.imageFilename = filename
                            updatedOutfit.imageData = nil // 古い方式のデータをクリア
                        }
                        
                        outfit = updatedOutfit
                        displayedImage = Image(uiImage: .init(data: data) ?? .init())
                        storageManager.updateOutfit(outfit)
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
                    outfit.image
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
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var imageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            CardView(
                padding: 0,
                cornerRadius: DesignSystem.CornerRadius.premium,
                shadow: DesignSystem.Shadow.large
            ) {
                if let displayedImage {
                    displayedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .cornerRadius(DesignSystem.CornerRadius.premium)
                        .onTapGesture {
                            isShowingFullScreenImage = true
                        }
                } else {
                    outfit.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .cornerRadius(DesignSystem.CornerRadius.premium)
                        .onTapGesture {
                            isShowingFullScreenImage = true
                        }
                }
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textInverse)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.cardBackground, lineWidth: 2)
                            )
                    )
                    .designSystemShadow(DesignSystem.Shadow.medium)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
    
    @ViewBuilder
    private var categorySection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Button(action: {
                    print("🔍 カテゴリボタンタップ - 現在のカテゴリ数: \(categoryManager.categories.count)")
                    print("🔍 利用可能なカテゴリ: \(categoryManager.categories)")
                    showingCategoryPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("カテゴリー")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Text(outfit.category)
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.accent)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            categoryPickerSheet
                .onAppear {
                    print("🔍 カテゴリピッカーシート表示 - カテゴリ数: \(categoryManager.categories.count)")
                }
        }
    }
    
    @ViewBuilder
    private var categoryPickerSheet: some View {
        NavigationView {
            if categoryManager.categories.isEmpty {
                VStack {
                    Text("カテゴリがありません")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding()
                    
                    Text("カテゴリ数: \(categoryManager.categories.count)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .navigationTitle("カテゴリー選択")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("キャンセル") {
                    showingCategoryPicker = false
                }
                .foregroundColor(DesignSystem.Colors.accent))
            } else {
                List(categoryManager.categories, id: \.self) { category in
                    HStack {
                        Text(category)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(.primary)
                        Spacer()
                        if category == outfit.category {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.accent)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("🔍 カテゴリ選択: \(category)")
                        outfit.category = category
                        showingCategoryPicker = false
                        storageManager.updateOutfit(outfit)
                        print("🔍 アウトフィット更新完了: \(outfit.category)")
                    }
                }
                .navigationTitle("カテゴリー選択")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("キャンセル") {
                    showingCategoryPicker = false
                }
                .foregroundColor(DesignSystem.Colors.accent))
            }
        }
    }
    
    @ViewBuilder
    private var nameSection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("アイテム名")
                        .font(DesignSystem.Typography.headlineBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        if isEditingName {
                            outfit.name = editedName
                            storageManager.updateOutfit(outfit)
                        } else {
                            editedName = outfit.name
                        }
                        isEditingName.toggle()
                    }) {
                        Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isEditingName ? DesignSystem.Colors.success : DesignSystem.Colors.accent)
                    }
                }
                
                if isEditingName {
                    TextField("アイテム名を入力", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(DesignSystem.Typography.body)
                } else {
                    Text(outfit.name)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var memoSection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("メモ")
                        .font(DesignSystem.Typography.headlineBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        if isEditingMemo {
                            outfit.memo = editedMemo
                            storageManager.updateOutfit(outfit)
                        } else {
                            editedMemo = outfit.memo
                        }
                        isEditingMemo.toggle()
                    }) {
                        Image(systemName: isEditingMemo ? "checkmark.circle.fill" : "pencil.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isEditingMemo ? DesignSystem.Colors.success : DesignSystem.Colors.accent)
                    }
                }
                
                if isEditingMemo {
                    TextEditor(text: $editedMemo)
                        .frame(height: 100)
                        .padding(DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
                        )
                } else {
                    if outfit.memo.isEmpty {
                        Text("メモがありません")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .italic()
                    } else {
                        Text(outfit.memo)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var itemsSection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("アイテム")
                        .font(DesignSystem.Typography.headlineBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button("編集") {
                        editedItemNames = outfit.itemNames
                        showingItemEditor = true
                    }
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.accent)
                }
                
                if outfit.itemNames.isEmpty {
                    Text("アイテムが登録されていません")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .italic()
                } else {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        ForEach(outfit.itemNames.indices, id: \.self) { index in
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Circle()
                                    .fill(DesignSystem.Colors.accent)
                                    .frame(width: 6, height: 6)
                                Text(outfit.itemNames[index])
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingItemEditor) {
            itemEditorSheet
        }
    }
    
    @ViewBuilder
    private var itemEditorSheet: some View {
        NavigationView {
            ItemListEditorView(itemNames: $editedItemNames, onSave: {
                outfit.itemNames = editedItemNames
                storageManager.updateOutfit(outfit)
                showingItemEditor = false
            }, itemNameManager: itemNameManager)
        }
    }
    
    @ViewBuilder
    private var wearHistorySection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("着用履歴")
                    .font(DesignSystem.Typography.headlineBold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if outfit.lastWornDates.isEmpty {
                    Text("まだ着用していません")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .italic()
                } else {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        ForEach(outfit.lastWornDates, id: \.self) { date in
                            Text(dateFormatter.string(from: date))
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                
                if outfit.isWornToday {
                    PrimaryButton("今日の着用を取り消す", icon: "tshirt.fill") {
                        var updatedClothing = outfit
                        updatedClothing.unwearToday()
                        outfit = updatedClothing
                        storageManager.updateOutfit(outfit)
                    }
                } else {
                    Button(action: {
                        var updatedClothing = outfit
                        updatedClothing.wearToday()
                        outfit = updatedClothing
                        storageManager.updateOutfit(outfit)
                    }) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "tshirt")
                                .font(.system(size: 16, weight: .medium))
                            Text("今日着る")
                                .font(DesignSystem.Typography.bodyMedium)
                        }
                    }
                    .accentButtonStyle()
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                DesignSystem.Colors.background,
                DesignSystem.Colors.backgroundSecondary
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("戻る")
                    .font(DesignSystem.Typography.bodyMedium)
            }
            .foregroundColor(DesignSystem.Colors.accent)
        }
    }
    
    // お気に入り切り替え
    private func toggleFavorite() {
        outfit.isFavorite.toggle()
        storageManager.updateOutfit(outfit)
    }
    
    @ViewBuilder
    private var favoriteSection: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            HStack(spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("お気に入り")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(outfit.isFavorite ? "登録済み" : "未登録")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(outfit.isFavorite ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: toggleFavorite) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .medium))
                        
                        Text(outfit.isFavorite ? "解除" : "登録")
                            .font(DesignSystem.Typography.bodyMedium)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(outfit.isFavorite ? .red : DesignSystem.Colors.accent)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                            .fill(outfit.isFavorite ? Color.red.opacity(0.1) : DesignSystem.Colors.accent.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                            .stroke(outfit.isFavorite ? Color.red : DesignSystem.Colors.accent, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    private var trailingButtons: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            favoriteButton
            deleteButton
        }
    }
    
    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(outfit.isFavorite ? .red : DesignSystem.Colors.accent)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            showingDeleteConfirmation = true
        }) {
            Image(systemName: "trash")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.error)
        }
    }
}

