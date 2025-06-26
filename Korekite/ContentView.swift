//
//  ContentView.swift
//  Korekite
//
//  Created by 国米宏司 on 2025/04/20.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var categoryManager = CategoryManager()
    @StateObject private var storageManager = StorageManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var itemNameManager = ItemNameManager()
    @StateObject private var searchManager = SearchManager()
    @AppStorage("selectedCategory") private var selectedCategory: String?
    @State private var showingAddClothing = false
    @State private var showingAnalytics = false
    
    // パフォーマンス向上のためのキャッシュ
    @State private var cachedFilteredItems: [Outfit] = []
    @State private var cachedRecommendedItems: [Outfit] = []
    
    // 2列のグリッドレイアウト
    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.xs)
    ]
    
    var filteredItems: [Outfit] {
        return cachedFilteredItems
    }
    
    var recommendedItems: [Outfit] {
        return cachedRecommendedItems
    }
    
    // メインコンテンツビュー（コンパイラタイムアウト回避）
    var mainContentView: some View {
        VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
            headerSpacerView
            weatherSectionView
            categorySelectionView
            searchFilterView
            outfitGridView
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }
    
    // ヘッダースペーサー
    var headerSpacerView: some View {
        Spacer()
            .frame(height: 40)
    }
    
    // 天気セクション
    var weatherSectionView: some View {
        Group {
            if let weatherInfo = weatherService.weatherInfo {
                weatherInfoCard(weatherInfo)
            } else if weatherService.isLoading {
                weatherLoadingCard
            } else {
                weatherUnavailableCard
            }
        }
    }
    
    // カテゴリ選択
    var categorySelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                allCategoryButton
                categoryButtons
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // 検索フィルタ
    var searchFilterView: some View {
        SearchAndFilterView(searchManager: searchManager, categoryManager: categoryManager)
            .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // アウトフィットグリッド
    var outfitGridView: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(filteredItems) { item in
                outfitNavigationLink(for: item)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // アウトフィットナビゲーションリンク
    func outfitNavigationLink(for item: Outfit) -> some View {
        NavigationLink(destination: outfitDetailView(for: item)) {
            OutfitCard(outfit: item, storageManager: storageManager)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // アウトフィット詳細ビュー
    func outfitDetailView(for item: Outfit) -> some View {
        OutfitDetailView(
            outfit: binding(for: item),
            categoryManager: categoryManager,
            storageManager: storageManager,
            itemNameManager: itemNameManager
        )
    }
    
    // 天気情報カード
    func weatherInfoCard(_ weatherInfo: WeatherInfo) -> some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("天気: \(weatherInfo.description)")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Spacer()
                    temperatureView(weatherInfo)
                }
                
                Text("おすすめカテゴリ: \(weatherInfo.recommendedCategory)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                if !recommendedItems.isEmpty {
                    recommendedItemsScrollView
                }
            }
        }
        .onTapGesture {
            handleWeatherTap()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // 温度表示
    func temperatureView(_ weatherInfo: WeatherInfo) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(Int(weatherInfo.tempMin))°C")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(.blue)
            Text("/")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            Text("\(Int(weatherInfo.tempMax))°C")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(.red)
        }
    }
    
    // おすすめアイテムスクロールビュー
    var recommendedItemsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(recommendedItems.prefix(3)) { item in
                    recommendedItemLink(for: item)
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    // おすすめアイテムリンク
    func recommendedItemLink(for item: Outfit) -> some View {
        NavigationLink(destination: outfitDetailView(for: item)) {
            item.image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 60, height: 60)
                .cornerRadius(DesignSystem.CornerRadius.image)
                .clipped()
        }
    }
    
    // 天気ローディングカード
    var weatherLoadingCard: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ProgressView()
                    .tint(DesignSystem.Colors.accent)
                Text("天気情報を取得中...")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // 天気利用不可カード
    var weatherUnavailableCard: some View {
        CardView(padding: DesignSystem.Spacing.cardPadding) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("天気情報が利用できません")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    PrimaryButton("位置情報を許可", icon: "location") {
                        locationManager.requestLocation()
                    }
                    
                    SecondaryButton("テストデータ", icon: "flask") {
                        createTestWeatherData()
                    }
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // すべてカテゴリボタン
    var allCategoryButton: some View {
        EnhancedCategoryButton(
            "すべて",
            isSelected: selectedCategory == nil || selectedCategory?.isEmpty == true,
            count: storageManager.outfits.count
        ) {
            selectedCategory = nil
        }
    }
    
    // カテゴリボタン群
    var categoryButtons: some View {
        ForEach(categoryManager.categories, id: \.self) { category in
            let count = storageManager.outfits.filter { $0.category == category }.count
            EnhancedCategoryButton(
                category,
                isSelected: selectedCategory == category,
                count: count
            ) {
                selectedCategory = category
            }
        }
    }
    
    var body: some View {
        NavigationView {
            mainScrollView
                .background(backgroundGradient)
                .navigationBarHidden(true)
                .overlay(topNavigationOverlay)
                .overlay(floatingActionButtonOverlay)
                .sheet(isPresented: $showingAddClothing) {
                    AddOutfitView(categoryManager: categoryManager, storageManager: storageManager, weatherService: weatherService)
                }
                .sheet(isPresented: $showingAnalytics) {
                    AnalyticsView(storageManager: storageManager)
                }
                .onAppear { handleOnAppear() }
                .onChange(of: locationManager.location) { _, location in handleLocationChange(location) }
                .onChange(of: storageManager.outfits) { _, _ in handleDataChange() }
                .onChange(of: selectedCategory) { _, _ in handleDataChange() }
                .onChange(of: searchManager.searchText) { _, _ in handleDataChange() }
                .onChange(of: weatherService.weatherInfo) { _, _ in handleWeatherChange() }
                .errorAlert(storageManager.errorManager)
        }
    }
    
    // メインスクロールビュー
    var mainScrollView: some View {
        ScrollView {
            mainContentView
        }
    }
    
    // 背景グラデーション
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                DesignSystem.Colors.background,
                DesignSystem.Colors.backgroundSecondary
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // トップナビゲーションオーバーレイ
    var topNavigationOverlay: some View {
        VStack {
            topNavigationBar
            Spacer()
        }
    }
    
    // トップナビゲーションバー
    var topNavigationBar: some View {
        HStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            
            Spacer()
            
            Button(action: { showingAnalytics = true }) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.accent)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
    }
    
    // フローティングアクションボタンオーバーレイ
    var floatingActionButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(icon: "plus") {
                    showingAddClothing = true
                }
                .padding(.trailing, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
    }
    
    // イベントハンドラメソッド
    private func handleOnAppear() {
        locationManager.requestLocation()
        
        // 初回のみ既存データからアイテム名を初期化
        if itemNameManager.allItemNames.isEmpty {
            itemNameManager.initializeFromExistingData(storageManager.outfits)
        }
        
        // キャッシュを更新
        Task {
            await updateCaches()
        }
    }
    
    private func handleLocationChange(_ location: CLLocation?) {
        if let location = location {
            weatherService.fetchWeather(for: location)
        }
    }
    
    private func handleDataChange() {
        Task {
            await updateCaches()
        }
    }
    
    private func handleWeatherChange() {
        Task {
            await updateRecommendedItemsCache()
        }
    }
    
    // 天気情報タップ時の処理
    private func handleWeatherTap() {
        guard let location = locationManager.location else {
            return
        }
        
        // 1時間以内に取得済みの場合は何もしない
        if weatherService.shouldFetchWeather() {
            weatherService.refreshWeather(for: location)
        }
    }
    
    // テスト用天気データを作成
    private func createTestWeatherData() {
        print("🧪 テスト天気データを作成中...")
        let testWeatherInfo = WeatherInfo(
            temperature: 22.0,
            tempMin: 18.0,
            tempMax: 26.0,
            description: "晴れ（テストデータ）",
            icon: "01d",
            recommendedCategory: "涼しい"
        )
        weatherService.weatherInfo = testWeatherInfo
        weatherService.isLoading = false
        weatherService.errorMessage = nil
        print("✅ テスト天気データが設定されました: \(testWeatherInfo.description)")
    }
    
    // 認証ステータスを文字列に変換
    private func authStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "未決定"
        case .denied: return "拒否"
        case .restricted: return "制限"
        case .authorizedWhenInUse: return "使用中のみ許可"
        case .authorizedAlways: return "常に許可"
        @unknown default: return "不明"
        }
    }
    
    // キャッシュ更新メソッド（パフォーマンス向上）
    @MainActor
    private func updateCaches() async {
        await updateFilteredItemsCache()
        await updateRecommendedItemsCache()
    }
    
    @MainActor
    private func updateFilteredItemsCache() async {
        let baseItems: [Outfit]
        if let category = selectedCategory, !category.isEmpty {
            baseItems = storageManager.outfits.filter { $0.category == category }
        } else {
            baseItems = storageManager.outfits
        }
        
        let filtered = await searchManager.filteredAndSortedOutfitsAsync(baseItems)
        self.cachedFilteredItems = filtered
    }
    
    @MainActor
    private func updateRecommendedItemsCache() async {
        guard let weatherInfo = weatherService.weatherInfo else {
            self.cachedRecommendedItems = []
            return
        }
        
        // シンプルなフィルタリングなので直接実行
        let recommended = storageManager.outfits.filter { $0.category == weatherInfo.recommendedCategory }
        
        self.cachedRecommendedItems = recommended
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


#Preview {
    ContentView()
}

