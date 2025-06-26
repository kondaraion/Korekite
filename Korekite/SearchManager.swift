import Foundation
import SwiftUI

class SearchManager: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategories: Set<String> = []
    @Published var selectedSortOption: SortOption = .dateAdded
    @Published var showFavoritesOnly = false
    @Published var showUnwornOnly = false
    @Published var showRecentlyWornOnly = false
    
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
    }
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || 
        !selectedCategories.isEmpty || 
        showFavoritesOnly || 
        showUnwornOnly || 
        showRecentlyWornOnly
    }
}