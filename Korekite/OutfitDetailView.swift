import SwiftUI
import PhotosUI

struct OutfitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var outfit: Outfit
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var itemNameManager: ItemNameManager
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
                // プレミアムな画像表示
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
                    
                    // エレガントな編集ボタン
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
                
                // ファッション情報セクション
                CardView(padding: DesignSystem.Spacing.cardPadding) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // カテゴリー選択
                        Button(action: {
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
                        NavigationView {
                            List(categoryManager.categories, id: \.self) { category in
                                Button(action: {
                                    outfit.category = category
                                    showingCategoryPicker = false
                                    storageManager.updateOutfit(outfit)
                                }) {
                                    HStack {
                                        Text(category)
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                        Spacer()
                                        if category == outfit.category {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(DesignSystem.Colors.accent)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .navigationTitle("カテゴリー選択")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button("キャンセル") {
                                showingCategoryPicker = false
                            }
                            .foregroundColor(DesignSystem.Colors.accent))
                        }
                    }
                
                // メモセクション
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
                
                // アイテムセクション
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
                
                // 着用履歴セクション
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
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.background,
                    DesignSystem.Colors.backgroundSecondary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                dismiss()
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("戻る")
                        .font(DesignSystem.Typography.bodyMedium)
                }
                .foregroundColor(DesignSystem.Colors.accent)
            },
            trailing: Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.error)
            }
        )
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
                ItemListEditorView(itemNames: $editedItemNames, itemNameManager: itemNameManager) {
                    outfit.itemNames = editedItemNames
                    storageManager.updateOutfit(outfit)
                    showingItemEditor = false
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        var updatedClothing = outfit
                        updatedClothing.imageData = data
                        outfit = updatedClothing
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
}

