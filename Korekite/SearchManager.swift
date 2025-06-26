import Foundation
import SwiftUI

class SearchManager: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategories: Set<String> = []
    @Published var selectedSortOption: SortOption = .dateAdded
    @Published var showFavoritesOnly = false
    @Published var showUnwornOnly = false
    @Published var showRecentlyWornOnly = false
    @Published var isFiltering = false
    
    // フィルタリング結果のキャッシュ
    private var cachedResults: [Outfit] = []
    private var lastFilterHash: Int = 0
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "追加日"
        case name = "名前"
        case category = "カテゴリー"
        case wearCount = "着用回数"
        case lastWorn = "最終着用"
        
        var systemImage: String {
            switch self {
            case .dateAdded: return "calendar.badge.plus"
            case .name: return "textformat.abc"
            case .category: return "folder"
            case .wearCount: return "chart.bar"
            case .lastWorn: return "clock"
            }
        }
    }
    
    func filteredAndSortedOutfits(_ outfits: [Outfit]) -> [Outfit] {
        // フィルタ条件のハッシュを作成
        let currentHash = calculateFilterHash(outfits: outfits)
        
        // キャッシュが有効な場合は結果を返す
        if currentHash == lastFilterHash && !cachedResults.isEmpty {
            return cachedResults
        }
        
        // 同期的にフィルタリングを実行（UIの応答性を保つため）
        let result = performFiltering(outfits)
        
        // キャッシュを更新
        cachedResults = result
        lastFilterHash = currentHash
        
        return result
    }
    
    // 非同期でフィルタリングを実行（重い処理用）
    func filteredAndSortedOutfitsAsync(_ outfits: [Outfit]) async -> [Outfit] {
        let currentHash = calculateFilterHash(outfits: outfits)
        
        // キャッシュが有効な場合は結果を返す
        if currentHash == lastFilterHash && !cachedResults.isEmpty {
            return cachedResults
        }
        
        await MainActor.run {
            isFiltering = true
        }
        
        let result = await Task.detached(priority: .userInitiated) {
            return self.performFiltering(outfits)
        }.value
        
        await MainActor.run {
            self.cachedResults = result
            self.lastFilterHash = currentHash
            self.isFiltering = false
        }
        
        return result
    }
    
    // 実際のフィルタリング処理
    private func performFiltering(_ outfits: [Outfit]) -> [Outfit] {
        var filtered = outfits
        
        // テキスト検索
        if !searchText.isEmpty {
            filtered = filtered.filter { outfit in
                outfit.name.localizedCaseInsensitiveContains(searchText) ||
                outfit.category.localizedCaseInsensitiveContains(searchText) ||
                outfit.memo.localizedCaseInsensitiveContains(searchText) ||
                outfit.itemNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // カテゴリフィルタ
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { selectedCategories.contains($0.category) }
        }
        
        // お気に入りフィルタ
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // 未着用フィルタ
        if showUnwornOnly {
            filtered = filtered.filter { $0.wearHistory.isEmpty }
        }
        
        // 最近着用フィルタ（過去7日間）
        if showRecentlyWornOnly {
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            filtered = filtered.filter { outfit in
                outfit.wearHistory.contains { $0 >= sevenDaysAgo }
            }
        }
        
        // ソート
        return sortOutfits(filtered)
    }
    
    // フィルタ条件のハッシュを計算
    private func calculateFilterHash(outfits: [Outfit]) -> Int {
        var hasher = Hasher()
        hasher.combine(searchText)
        hasher.combine(selectedCategories)
        hasher.combine(selectedSortOption)
        hasher.combine(showFavoritesOnly)
        hasher.combine(showUnwornOnly)
        hasher.combine(showRecentlyWornOnly)
        hasher.combine(outfits.count)
        return hasher.finalize()
    }
    
    private func sortOutfits(_ outfits: [Outfit]) -> [Outfit] {
        switch selectedSortOption {
        case .dateAdded:
            return outfits.sorted { $0.id.uuidString < $1.id.uuidString }
        case .name:
            return outfits.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .category:
            return outfits.sorted { $0.category.localizedCompare($1.category) == .orderedAscending }
        case .wearCount:
            return outfits.sorted { $0.wearHistory.count > $1.wearHistory.count }
        case .lastWorn:
            return outfits.sorted { outfit1, outfit2 in
                let date1 = outfit1.wearHistory.max() ?? Date.distantPast
                let date2 = outfit2.wearHistory.max() ?? Date.distantPast
                return date1 > date2
            }
        }
    }
    
    func clearAllFilters() {
        searchText = ""
        selectedCategories.removeAll()
        showFavoritesOnly = false
        showUnwornOnly = false
        showRecentlyWornOnly = false
        
        // キャッシュもクリア
        cachedResults.removeAll()
        lastFilterHash = 0
    }
    
    // キャッシュを無効化
    func invalidateCache() {
        cachedResults.removeAll()
        lastFilterHash = 0
    }
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || 
        !selectedCategories.isEmpty || 
        showFavoritesOnly || 
        showUnwornOnly || 
        showRecentlyWornOnly
    }
}