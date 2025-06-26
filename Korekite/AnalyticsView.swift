import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var storageManager: StorageManager
    @StateObject private var analyticsManager = AnalyticsManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Analytics", selection: $selectedTab) {
                    Text("概要").tag(0)
                    Text("着用頻度").tag(1)
                    Text("季節統計").tag(2)
                    Text("未使用").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                TabView(selection: $selectedTab) {
                    OverviewTab(storageManager: storageManager, analyticsManager: analyticsManager)
                        .tag(0)
                    
                    WearFrequencyTab(storageManager: storageManager, analyticsManager: analyticsManager)
                        .tag(1)
                    
                    SeasonalStatsTab(storageManager: storageManager, analyticsManager: analyticsManager)
                        .tag(2)
                    
                    UnusedItemsTab(storageManager: storageManager, analyticsManager: analyticsManager)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("統計・分析")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var analyticsManager: AnalyticsManager
    
    var overallStats: AnalyticsManager.OverallStats {
        analyticsManager.getOverallStats(for: storageManager.outfits)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                // 基本統計
                CardView(padding: DesignSystem.Spacing.cardPadding) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(DesignSystem.Colors.accent)
                            Text("基本統計")
                                .font(DesignSystem.Typography.headlineBold)
                        }
                        
                        HStack {
                            StatCard(
                                value: "\(overallStats.totalOutfits)",
                                label: "総アイテム数",
                                icon: "tshirt",
                                color: .blue
                            )
                            
                            StatCard(
                                value: "\(overallStats.totalWears)",
                                label: "総着用回数",
                                icon: "repeat",
                                color: .green
                            )
                        }
                        
                        HStack {
                            StatCard(
                                value: String(format: "%.1f", overallStats.averageWearsPerOutfit),
                                label: "平均着用回数",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .orange
                            )
                            
                            StatCard(
                                value: "\(Int(overallStats.utilizationRate * 100))%",
                                label: "着用率",
                                icon: "checkmark.circle",
                                color: .purple
                            )
                        }
                    }
                }
                
                // 最もよく着る服
                if let mostWorn = overallStats.mostWornOutfit {
                    CardView(padding: DesignSystem.Spacing.cardPadding) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("最もよく着る服")
                                    .font(DesignSystem.Typography.headlineBold)
                            }
                            
                            HStack {
                                mostWorn.image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(DesignSystem.CornerRadius.small)
                                    .clipped()
                                
                                VStack(alignment: .leading) {
                                    Text(mostWorn.name)
                                        .font(DesignSystem.Typography.bodyMedium)
                                        .fontWeight(.medium)
                                    
                                    Text("\(mostWorn.wearHistory.count)回着用")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // お気に入りカテゴリ
                if let favoriteCategory = overallStats.favoriteCategory {
                    CardView(padding: DesignSystem.Spacing.cardPadding) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("お気に入りカテゴリ")
                                    .font(DesignSystem.Typography.headlineBold)
                            }
                            
                            Text(favoriteCategory)
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.accent)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Wear Frequency Tab

struct WearFrequencyTab: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var analyticsManager: AnalyticsManager
    
    var wearFrequencyData: [AnalyticsManager.WearFrequencyData] {
        analyticsManager.getWearFrequencyData(for: storageManager.outfits)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                // 着用頻度分布
                CardView(padding: DesignSystem.Spacing.cardPadding) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("着用頻度分布")
                            .font(DesignSystem.Typography.headlineBold)
                        
                        ForEach(AnalyticsManager.WearFrequency.allCases, id: \.self) { frequency in
                            let count = wearFrequencyData.filter { $0.wearFrequencyCategory == frequency }.count
                            
                            HStack {
                                Image(systemName: frequency.systemImage)
                                    .foregroundColor(frequency.color)
                                    .frame(width: 20)
                                
                                Text(frequency.rawValue)
                                    .font(DesignSystem.Typography.body)
                                
                                Spacer()
                                
                                Text("\(count)個")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                }
                
                // 着用頻度ランキング
                CardView(padding: DesignSystem.Spacing.cardPadding) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("着用回数ランキング")
                            .font(DesignSystem.Typography.headlineBold)
                        
                        ForEach(Array(wearFrequencyData.sorted { $0.wearCount > $1.wearCount }.prefix(5).enumerated()), id: \.offset) { index, data in
                            HStack {
                                Text("\(index + 1)")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(getRankColor(index))
                                    .frame(width: 30)
                                
                                data.outfit.image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(DesignSystem.CornerRadius.small)
                                    .clipped()
                                
                                VStack(alignment: .leading) {
                                    Text(data.outfit.name)
                                        .font(DesignSystem.Typography.bodyMedium)
                                        .lineLimit(1)
                                    
                                    Text("\(data.wearCount)回")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func getRankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return DesignSystem.Colors.textSecondary
        }
    }
}

// MARK: - Seasonal Stats Tab

struct SeasonalStatsTab: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var analyticsManager: AnalyticsManager
    
    var seasonalStats: [AnalyticsManager.SeasonalStats] {
        analyticsManager.getSeasonalStats(for: storageManager.outfits)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(seasonalStats) { stats in
                    CardView(padding: DesignSystem.Spacing.cardPadding) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: stats.season.systemImage)
                                    .foregroundColor(stats.season.color)
                                
                                Text(stats.season.rawValue)
                                    .font(DesignSystem.Typography.headlineBold)
                                
                                Spacer()
                                
                                Text("\(stats.totalWears)回")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            if !stats.favoriteCategories.isEmpty {
                                Text("よく着るカテゴリ")
                                    .font(DesignSystem.Typography.body)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    ForEach(stats.favoriteCategories.prefix(3), id: \.self) { category in
                                        Text(category)
                                            .font(DesignSystem.Typography.caption)
                                            .padding(.horizontal, DesignSystem.Spacing.sm)
                                            .padding(.vertical, DesignSystem.Spacing.xs)
                                            .background(stats.season.color.opacity(0.1))
                                            .foregroundColor(stats.season.color)
                                            .cornerRadius(DesignSystem.CornerRadius.small)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Unused Items Tab

struct UnusedItemsTab: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var analyticsManager: AnalyticsManager
    
    var unusedAnalysis: AnalyticsManager.UnusedItemAnalysis {
        analyticsManager.getUnusedItemAnalysis(for: storageManager.outfits)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                // 未使用アイテム概要
                CardView(padding: DesignSystem.Spacing.cardPadding) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Image(systemName: "moon.zzz")
                                .foregroundColor(.gray)
                            Text("未使用アイテム")
                                .font(DesignSystem.Typography.headlineBold)
                        }
                        
                        Text("\(unusedAnalysis.totalUnusedItems)個のアイテムが未使用です")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // カテゴリ別未使用
                if !unusedAnalysis.unusedByCategory.isEmpty {
                    CardView(padding: DesignSystem.Spacing.cardPadding) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("カテゴリ別未使用アイテム")
                                .font(DesignSystem.Typography.headlineBold)
                            
                            ForEach(Array(unusedAnalysis.unusedByCategory.sorted { $0.value > $1.value }), id: \.key) { category, count in
                                HStack {
                                    Text(category)
                                        .font(DesignSystem.Typography.body)
                                    
                                    Spacer()
                                    
                                    Text("\(count)個")
                                        .font(DesignSystem.Typography.bodyMedium)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            }
                        }
                    }
                }
                
                // 提案アクション
                if !unusedAnalysis.suggestedActions.isEmpty {
                    CardView(padding: DesignSystem.Spacing.cardPadding) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: "lightbulb")
                                    .foregroundColor(.yellow)
                                Text("おすすめアクション")
                                    .font(DesignSystem.Typography.headlineBold)
                            }
                            
                            ForEach(unusedAnalysis.suggestedActions, id: \.self) { action in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(DesignSystem.Colors.accent)
                                        .font(.caption)
                                    
                                    Text(action)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - StatCard Component

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.small)
    }
}