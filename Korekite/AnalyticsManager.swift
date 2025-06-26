import Foundation
import SwiftUI

class AnalyticsManager: ObservableObject {
    
    // MARK: - 着用頻度分析
    
    struct WearFrequencyData: Identifiable {
        let id = UUID()
        let outfit: Outfit
        let wearCount: Int
        let lastWornDate: Date?
        let averageDaysBetweenWears: Double?
        
        var wearFrequencyCategory: WearFrequency {
            switch wearCount {
            case 0: return .unworn
            case 1...3: return .rare
            case 4...8: return .occasional
            case 9...15: return .frequent
            default: return .veryFrequent
            }
        }
    }
    
    enum WearFrequency: String, CaseIterable {
        case unworn = "未着用"
        case rare = "稀"
        case occasional = "時々"
        case frequent = "頻繁"
        case veryFrequent = "非常に頻繁"
        
        var color: Color {
            switch self {
            case .unworn: return .gray
            case .rare: return .red
            case .occasional: return .orange
            case .frequent: return .blue
            case .veryFrequent: return .green
            }
        }
        
        var systemImage: String {
            switch self {
            case .unworn: return "moon.zzz"
            case .rare: return "1.circle"
            case .occasional: return "2.circle"
            case .frequent: return "3.circle"
            case .veryFrequent: return "star.circle"
            }
        }
    }
    
    func getWearFrequencyData(for outfits: [Outfit]) -> [WearFrequencyData] {
        return outfits.map { outfit in
            let wearCount = outfit.wearHistory.count
            let lastWornDate = outfit.wearHistory.max()
            let averageDaysBetweenWears = calculateAverageDaysBetweenWears(outfit.wearHistory)
            
            return WearFrequencyData(
                outfit: outfit,
                wearCount: wearCount,
                lastWornDate: lastWornDate,
                averageDaysBetweenWears: averageDaysBetweenWears
            )
        }
    }
    
    private func calculateAverageDaysBetweenWears(_ wearHistory: [Date]) -> Double? {
        guard wearHistory.count > 1 else { return nil }
        
        let sortedDates = wearHistory.sorted()
        var totalDays: Double = 0
        
        for i in 1..<sortedDates.count {
            let daysBetween = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            totalDays += Double(daysBetween)
        }
        
        return totalDays / Double(sortedDates.count - 1)
    }
    
    // MARK: - 季節別統計
    
    struct SeasonalStats: Identifiable {
        let id = UUID()
        let season: Season
        let totalWears: Int
        let favoriteCategories: [String]
        let favoriteOutfits: [Outfit]
    }
    
    enum Season: String, CaseIterable {
        case spring = "春"
        case summer = "夏"
        case autumn = "秋"
        case winter = "冬"
        
        var color: Color {
            switch self {
            case .spring: return .green
            case .summer: return .yellow
            case .autumn: return .orange
            case .winter: return .blue
            }
        }
        
        var systemImage: String {
            switch self {
            case .spring: return "leaf"
            case .summer: return "sun.max"
            case .autumn: return "leaf.fill"
            case .winter: return "snowflake"
            }
        }
        
        var months: [Int] {
            switch self {
            case .spring: return [3, 4, 5]
            case .summer: return [6, 7, 8]
            case .autumn: return [9, 10, 11]
            case .winter: return [12, 1, 2]
            }
        }
    }
    
    func getSeasonalStats(for outfits: [Outfit]) -> [SeasonalStats] {
        return Season.allCases.map { season in
            let seasonalWears = getSeasonalWears(outfits: outfits, season: season)
            let totalWears = seasonalWears.reduce(0) { $0 + $1.value.count }
            
            // カテゴリ別の着用回数を計算
            var categoryWearCounts: [String: Int] = [:]
            for (outfit, wearDates) in seasonalWears {
                categoryWearCounts[outfit.category, default: 0] += wearDates.count
            }
            
            let favoriteCategories = categoryWearCounts
                .sorted { $0.value > $1.value }
                .prefix(3)
                .map { $0.key }
            
            // よく着る服を特定
            let favoriteOutfits = seasonalWears
                .sorted { $0.value.count > $1.value.count }
                .prefix(3)
                .map { $0.key }
            
            return SeasonalStats(
                season: season,
                totalWears: totalWears,
                favoriteCategories: Array(favoriteCategories),
                favoriteOutfits: Array(favoriteOutfits)
            )
        }
    }
    
    private func getSeasonalWears(outfits: [Outfit], season: Season) -> [Outfit: [Date]] {
        var seasonalWears: [Outfit: [Date]] = [:]
        
        for outfit in outfits {
            let seasonalDates = outfit.wearHistory.filter { date in
                let month = Calendar.current.component(.month, from: date)
                return season.months.contains(month)
            }
            if !seasonalDates.isEmpty {
                seasonalWears[outfit] = seasonalDates
            }
        }
        
        return seasonalWears
    }
    
    // MARK: - 未使用アイテム検出
    
    struct UnusedItemAnalysis {
        let totalUnusedItems: Int
        let unusedByCategory: [String: Int]
        let oldestUnusedItems: [Outfit]
        let suggestedActions: [String]
    }
    
    func getUnusedItemAnalysis(for outfits: [Outfit]) -> UnusedItemAnalysis {
        let unusedItems = outfits.filter { $0.wearHistory.isEmpty }
        
        // カテゴリ別未使用アイテム数
        var unusedByCategory: [String: Int] = [:]
        for item in unusedItems {
            unusedByCategory[item.category, default: 0] += 1
        }
        
        // 古い未使用アイテム（UUIDの文字列比較で近似的に判定）
        let oldestUnusedItems = Array(unusedItems.sorted { $0.id.uuidString < $1.id.uuidString }.prefix(5))
        
        // 提案アクション
        var suggestedActions: [String] = []
        
        if unusedItems.count > 10 {
            suggestedActions.append("整理を検討: 未使用アイテムが多数あります")
        }
        
        if let maxCategory = unusedByCategory.max(by: { $0.value < $1.value }), maxCategory.value > 3 {
            suggestedActions.append("\(maxCategory.key)カテゴリの見直しを検討")
        }
        
        if unusedItems.count > outfits.count / 3 {
            suggestedActions.append("全体的なワードローブの見直しが有効かもしれません")
        }
        
        return UnusedItemAnalysis(
            totalUnusedItems: unusedItems.count,
            unusedByCategory: unusedByCategory,
            oldestUnusedItems: oldestUnusedItems,
            suggestedActions: suggestedActions
        )
    }
    
    // MARK: - 全体統計
    
    struct OverallStats {
        let totalOutfits: Int
        let totalWears: Int
        let averageWearsPerOutfit: Double
        let mostWornOutfit: Outfit?
        let favoriteCategory: String?
        let utilizationRate: Double // 着用率
    }
    
    func getOverallStats(for outfits: [Outfit]) -> OverallStats {
        let totalOutfits = outfits.count
        let totalWears = outfits.reduce(0) { $0 + $1.wearHistory.count }
        let averageWearsPerOutfit = totalOutfits > 0 ? Double(totalWears) / Double(totalOutfits) : 0
        
        let mostWornOutfit = outfits.max { $0.wearHistory.count < $1.wearHistory.count }
        
        // カテゴリ別着用回数
        var categoryWearCounts: [String: Int] = [:]
        for outfit in outfits {
            categoryWearCounts[outfit.category, default: 0] += outfit.wearHistory.count
        }
        
        let favoriteCategory = categoryWearCounts.max { $0.value < $1.value }?.key
        
        // 着用率（少なくとも1回着用したアイテムの割合）
        let wornOutfits = outfits.filter { !$0.wearHistory.isEmpty }.count
        let utilizationRate = totalOutfits > 0 ? Double(wornOutfits) / Double(totalOutfits) : 0
        
        return OverallStats(
            totalOutfits: totalOutfits,
            totalWears: totalWears,
            averageWearsPerOutfit: averageWearsPerOutfit,
            mostWornOutfit: mostWornOutfit,
            favoriteCategory: favoriteCategory,
            utilizationRate: utilizationRate
        )
    }
}