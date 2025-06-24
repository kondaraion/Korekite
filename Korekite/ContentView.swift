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
    @AppStorage("selectedCategory") private var selectedCategory: String?
    @State private var showingAddClothing = false
    
    // 2列のグリッドレイアウト
    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.xs)
    ]
    
    var filteredItems: [Outfit] {
        if let category = selectedCategory, !category.isEmpty {
            return storageManager.outfits.filter { $0.category == category }
        }
        return storageManager.outfits
    }
    
    var recommendedItems: [Outfit] {
        guard let weatherInfo = weatherService.weatherInfo else {
            return []
        }
        return storageManager.outfits.filter { $0.category == weatherInfo.recommendedCategory }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    // 天気情報表示
                    if let weatherInfo = weatherService.weatherInfo {
                        CardView(padding: DesignSystem.Spacing.cardPadding) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("天気: \(weatherInfo.description)")
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    Spacer()
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
                                
                                Text("おすすめカテゴリ: \(weatherInfo.recommendedCategory)")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                // おすすめアイテムを表示
                                if !recommendedItems.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: DesignSystem.Spacing.sm) {
                                            ForEach(recommendedItems.prefix(3)) { item in
                                                NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: categoryManager, storageManager: storageManager, itemNameManager: itemNameManager)) {
                                                    item.image
                                                        .resizable()
                                                        .aspectRatio(1, contentMode: .fill)
                                                        .frame(width: 60, height: 60)
                                                        .cornerRadius(DesignSystem.CornerRadius.image)
                                                        .clipped()
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            handleWeatherTap()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    } else if weatherService.isLoading {
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
                    } else {
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
                    
                    // カテゴリー選択
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            EnhancedCategoryButton(
                                "すべて",
                                isSelected: selectedCategory == nil || selectedCategory?.isEmpty == true,
                                count: storageManager.outfits.count
                            ) {
                                selectedCategory = nil
                            }
                            
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
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // 服のグリッド
                    LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: categoryManager, storageManager: storageManager, itemNameManager: itemNameManager)) {
                                OutfitCard(outfit: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }
                .padding(.top, DesignSystem.Spacing.sm)
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
            .navigationBarHidden(true)
            .overlay(
                // 右下のFloating Action Button
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
            )
            .sheet(isPresented: $showingAddClothing) {
                AddOutfitView(categoryManager: categoryManager, storageManager: storageManager)
            }
            .onAppear {
                locationManager.requestLocation()
                
                // 初回のみ既存データからアイテム名を初期化
                if itemNameManager.allItemNames.isEmpty {
                    itemNameManager.initializeFromExistingData(storageManager.outfits)
                }
            }
            .onChange(of: locationManager.location) { location in
                if let location = location {
                    weatherService.fetchWeather(for: location)
                }
            }
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

