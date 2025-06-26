import SwiftUI

extension Notification.Name {
    static let outfitImageUpdated = Notification.Name("outfitImageUpdated")
}

struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: ShadowModifier
    
    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium,
        shadow: ShadowModifier = DesignSystem.Shadow.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .designSystemShadow(shadow)
    }
}

// MARK: - Specialized Card Components

struct WeatherCard: View {
    let weatherInfo: WeatherInfo
    let isLoading: Bool
    let onTap: () -> Void
    let recommendedItems: [Outfit]
    let categoryManager: CategoryManager
    let storageManager: StorageManager
    let itemNameManager: ItemNameManager
    
    var body: some View {
        CardView(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Weather Header
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        HStack {
                            Text("\(Int(weatherInfo.temperature))°C")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(.white)
                            
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                        }
                        
                        Text("\(Int(weatherInfo.tempMin))°C - \(Int(weatherInfo.tempMax))°C")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(weatherInfo.description)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: getWeatherIcon(weatherInfo.icon))
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        Text("おすすめ")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(weatherInfo.recommendedCategory)
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                }
                
                // Recommended Items
                if !recommendedItems.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("今日のおすすめコーディネート")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(recommendedItems.prefix(5)) { item in
                                    NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: categoryManager, storageManager: storageManager, itemNameManager: itemNameManager)) {
                                        item.image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(DesignSystem.CornerRadius.medium)
                                            .clipped()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    .scaleEffect(1.0)
                                    .animation(DesignSystem.Animation.quick, value: false)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }
        }
        .background(DesignSystem.Colors.weatherBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .designSystemShadow(DesignSystem.Shadow.large)
        .onTapGesture {
            onTap()
        }
    }
    
    private func getWeatherIcon(_ iconCode: String) -> String {
        switch iconCode {
        case let code where code.contains("01"): return "sun.max.fill"
        case let code where code.contains("02"): return "cloud.sun.fill"
        case let code where code.contains("03"), let code where code.contains("04"): return "cloud.fill"
        case let code where code.contains("09"), let code where code.contains("10"): return "cloud.rain.fill"
        case let code where code.contains("11"): return "cloud.bolt.fill"
        case let code where code.contains("13"): return "cloud.snow.fill"
        case let code where code.contains("50"): return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }
    
    private func binding(for item: Outfit) -> Binding<Outfit> {
        Binding(
            get: {
                if let index = storageManager.outfits.firstIndex(where: { $0.id == item.id }) {
                    return storageManager.outfits[index]
                }
                return item
            },
            set: { newValue in
                if let index = storageManager.outfits.firstIndex(where: { $0.id == newValue.id }) {
                    storageManager.outfits[index] = newValue
                    storageManager.saveOutfits()
                }
            }
        )
    }
}

struct OutfitCard: View {
    let outfit: Outfit
    @ObservedObject var storageManager: StorageManager
    @State private var cachedImage: UIImage?
    
    // 現在のお気に入り状態を取得
    private var currentOutfit: Outfit {
        if let index = storageManager.outfits.firstIndex(where: { $0.id == outfit.id }) {
            return storageManager.outfits[index]
        }
        return outfit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // プレミアムな画像表示
            ZStack {
                Group {
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: "tshirt")
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .background(DesignSystem.Colors.backgroundSecondary)
                    }
                }
                
                // エレガントなオーバーレイ
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // お気に入りボタン
                VStack {
                    HStack {
                        Spacer()
                        Button(action: toggleFavorite) {
                            Image(systemName: currentOutfit.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(currentOutfit.isFavorite ? .red : .white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        .padding(DesignSystem.Spacing.sm)
                    }
                    Spacer()
                }
            }
            .cornerRadius(DesignSystem.CornerRadius.image, corners: [.topLeft, .topRight])
            
            // 洗練された情報表示部分
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(currentOutfit.category)
                        .font(DesignSystem.Typography.categoryLabel)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // カテゴリーアイコン
                    Image(systemName: getCategoryIcon(currentOutfit.category))
                        .font(.system(size: 12))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                if !currentOutfit.memo.isEmpty {
                    Text(currentOutfit.memo)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
        }
        .cornerRadius(DesignSystem.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                .stroke(DesignSystem.Colors.cardBorder.opacity(0.5), lineWidth: 0.5)
        )
        .designSystemShadow(DesignSystem.Shadow.card)
        .scaleEffect(1.0)
        .animation(DesignSystem.Animation.smooth, value: false)
        .onAppear {
            Task {
                await loadImageAsync()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .outfitImageUpdated)) { notification in
            if let outfitId = notification.userInfo?["outfitId"] as? UUID, outfitId == outfit.id {
                Task {
                    await loadImageAsync()
                }
            }
        }
    }
    
    // 非同期で画像を読み込み（パフォーマンス向上）
    @MainActor
    private func loadImageAsync() async {
        guard cachedImage == nil else { return }
        
        // StorageManagerのメソッドは既にメインスレッド対応済みなので直接呼び出し
        let image = storageManager.getCachedUIImage(for: outfit)
        self.cachedImage = image
    }
    
    private func toggleFavorite() {
        var updatedOutfit = currentOutfit
        updatedOutfit.isFavorite.toggle()
        storageManager.updateOutfit(updatedOutfit)
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case let cat where cat.contains("アウター"): return "jacket"
        case let cat where cat.contains("トップス"): return "tshirt"
        case let cat where cat.contains("ボトムス"): return "pants"
        case let cat where cat.contains("シューズ"), let cat where cat.contains("靴"): return "shoe"
        case let cat where cat.contains("アクセサリー"): return "eye"
        case let cat where cat.contains("帽子"): return "hat"
        case let cat where cat.contains("バッグ"): return "bag"
        default: return "tshirt"
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    VStack(spacing: 20) {
        CardView {
            Text("Sample Card Content")
                .font(DesignSystem.Typography.headline)
        }
        
        let sampleWeatherInfo = WeatherInfo(
            temperature: 22.0,
            tempMin: 18.0,
            tempMax: 26.0,
            description: "晴れ",
            icon: "01d",
            recommendedCategory: "軽やか"
        )
        
        WeatherCard(
            weatherInfo: sampleWeatherInfo,
            isLoading: false,
            onTap: {},
            recommendedItems: [],
            categoryManager: CategoryManager(),
            storageManager: StorageManager(),
            itemNameManager: ItemNameManager()
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}