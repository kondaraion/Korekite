import SwiftUI

struct SearchAndFilterView: View {
    @ObservedObject var searchManager: SearchManager
    @ObservedObject var categoryManager: CategoryManager
    @State private var showingFilterSheet = false
    @State private var showingSortSheet = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 検索バー
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    TextField("服を検索...", text: $searchManager.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.backgroundSecondary)
                .cornerRadius(DesignSystem.CornerRadius.small)
                
                // フィルターボタン
                Button(action: { showingFilterSheet = true }) {
                    Image(systemName: searchManager.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundColor(searchManager.hasActiveFilters ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                        .font(.system(size: 20))
                }
                
                // ソートボタン
                Button(action: { showingSortSheet = true }) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.system(size: 20))
                }
            }
            
            // アクティブフィルター表示
            if searchManager.hasActiveFilters {
                activeFiltersView
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(searchManager: searchManager, categoryManager: categoryManager)
        }
        .sheet(isPresented: $showingSortSheet) {
            SortSheet(searchManager: searchManager)
        }
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                // 検索テキスト
                if !searchManager.searchText.isEmpty {
                    FilterChip(
                        text: "検索: \(searchManager.searchText)",
                        onRemove: { searchManager.searchText = "" }
                    )
                }
                
                // カテゴリフィルター
                ForEach(Array(searchManager.selectedCategories), id: \.self) { category in
                    FilterChip(
                        text: category,
                        onRemove: { searchManager.selectedCategories.remove(category) }
                    )
                }
                
                // 特殊フィルター
                if searchManager.showFavoritesOnly {
                    FilterChip(
                        text: "お気に入り",
                        onRemove: { searchManager.showFavoritesOnly = false }
                    )
                }
                
                if searchManager.showUnwornOnly {
                    FilterChip(
                        text: "未着用",
                        onRemove: { searchManager.showUnwornOnly = false }
                    )
                }
                
                if searchManager.showRecentlyWornOnly {
                    FilterChip(
                        text: "最近着用",
                        onRemove: { searchManager.showRecentlyWornOnly = false }
                    )
                }
                
                // 全クリアボタン
                Button("全てクリア") {
                    searchManager.clearAllFilters()
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.error)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(text)
                .font(DesignSystem.Typography.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Colors.accent.opacity(0.1))
        .foregroundColor(DesignSystem.Colors.accent)
        .cornerRadius(DesignSystem.CornerRadius.small)
    }
}

struct FilterSheet: View {
    @ObservedObject var searchManager: SearchManager
    @ObservedObject var categoryManager: CategoryManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("カテゴリー") {
                    ForEach(categoryManager.categories, id: \.self) { category in
                        HStack {
                            Text(category)
                            Spacer()
                            if searchManager.selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DesignSystem.Colors.accent)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if searchManager.selectedCategories.contains(category) {
                                searchManager.selectedCategories.remove(category)
                            } else {
                                searchManager.selectedCategories.insert(category)
                            }
                        }
                    }
                }
                
                Section("特別フィルター") {
                    Toggle("お気に入りのみ", isOn: $searchManager.showFavoritesOnly)
                    Toggle("未着用のみ", isOn: $searchManager.showUnwornOnly)
                    Toggle("最近着用のみ", isOn: $searchManager.showRecentlyWornOnly)
                }
                
                Section {
                    Button("全てクリア") {
                        searchManager.clearAllFilters()
                    }
                    .foregroundColor(DesignSystem.Colors.error)
                }
            }
            .navigationTitle("フィルター")
            .navigationBarItems(trailing: Button("完了") { dismiss() })
        }
    }
}

struct SortSheet: View {
    @ObservedObject var searchManager: SearchManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(SearchManager.SortOption.allCases, id: \.self) { option in
                    HStack {
                        Image(systemName: option.systemImage)
                            .foregroundColor(DesignSystem.Colors.accent)
                            .frame(width: 20)
                        
                        Text(option.rawValue)
                        
                        Spacer()
                        
                        if searchManager.selectedSortOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(DesignSystem.Colors.accent)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        searchManager.selectedSortOption = option
                        dismiss()
                    }
                }
            }
            .navigationTitle("並び替え")
            .navigationBarItems(trailing: Button("完了") { dismiss() })
        }
    }
}