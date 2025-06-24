import Foundation

class ItemNameManager: ObservableObject {
    @Published var allItemNames: Set<String> = []
    @Published var recentItemNames: [String] = []
    @Published var frequentItemNames: [(name: String, count: Int)] = []
    
    private let itemNamesKey = "allItemNames"
    private let recentItemNamesKey = "recentItemNames"
    private let itemFrequencyKey = "itemFrequency"
    private var itemFrequency: [String: Int] = [:]
    
    private let maxRecentItems = 10
    
    init() {
        loadData()
    }
    
    // すべてのアイテム名を取得（アルファベット順）
    var sortedItemNames: [String] {
        Array(allItemNames).sorted()
    }
    
    // 新しいアイテム名を追加
    func addItemName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // セットに追加（重複は自動的に除外される）
        allItemNames.insert(trimmedName)
        
        // 頻度を更新
        itemFrequency[trimmedName] = (itemFrequency[trimmedName] ?? 0) + 1
        
        // 最近使用したアイテムに追加
        addToRecentItems(trimmedName)
        
        // 頻度順でソート
        updateFrequentItems()
        
        // データを保存
        saveData()
    }
    
    // 複数のアイテム名を一括追加
    func addItemNames(_ names: [String]) {
        for name in names {
            addItemName(name)
        }
    }
    
    // 検索機能：部分一致でアイテム名を検索
    func searchItemNames(_ query: String) -> [String] {
        guard !query.isEmpty else { return sortedItemNames }
        
        let lowercaseQuery = query.lowercased()
        return sortedItemNames.filter { $0.lowercased().contains(lowercaseQuery) }
    }
    
    // カテゴリ別のおすすめアイテム名を取得（将来的な拡張用）
    func getRecommendedItemNames(for category: String? = nil) -> [String] {
        // 現在は頻度順で返すが、将来的にはカテゴリ別の学習も可能
        return Array(frequentItemNames.prefix(5).map { $0.name })
    }
    
    // 最近使用したアイテムに追加
    private func addToRecentItems(_ name: String) {
        // 既存の項目があれば削除
        recentItemNames.removeAll { $0 == name }
        
        // 先頭に追加
        recentItemNames.insert(name, at: 0)
        
        // 最大数を超えた場合は末尾を削除
        if recentItemNames.count > maxRecentItems {
            recentItemNames.removeLast()
        }
    }
    
    // 頻度順でアイテムを更新
    private func updateFrequentItems() {
        frequentItemNames = itemFrequency.map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // データを保存
    private func saveData() {
        // すべてのアイテム名を保存
        let itemNamesArray = Array(allItemNames)
        UserDefaults.standard.set(itemNamesArray, forKey: itemNamesKey)
        
        // 最近使用したアイテム名を保存
        UserDefaults.standard.set(recentItemNames, forKey: recentItemNamesKey)
        
        // 頻度データを保存
        if let encoded = try? JSONEncoder().encode(itemFrequency) {
            UserDefaults.standard.set(encoded, forKey: itemFrequencyKey)
        }
    }
    
    // データを読み込み
    private func loadData() {
        // すべてのアイテム名を読み込み
        if let itemNamesArray = UserDefaults.standard.array(forKey: itemNamesKey) as? [String] {
            allItemNames = Set(itemNamesArray)
        }
        
        // 最近使用したアイテム名を読み込み
        if let recentItems = UserDefaults.standard.array(forKey: recentItemNamesKey) as? [String] {
            recentItemNames = recentItems
        }
        
        // 頻度データを読み込み
        if let data = UserDefaults.standard.data(forKey: itemFrequencyKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            itemFrequency = decoded
            updateFrequentItems()
        }
    }
    
    // 既存のOutfitデータからアイテム名を初期化
    func initializeFromExistingData(_ outfits: [Outfit]) {
        var allNames: Set<String> = []
        var frequency: [String: Int] = [:]
        
        for outfit in outfits {
            for itemName in outfit.itemNames {
                let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty {
                    allNames.insert(trimmedName)
                    frequency[trimmedName] = (frequency[trimmedName] ?? 0) + 1
                }
            }
        }
        
        allItemNames = allNames
        itemFrequency = frequency
        updateFrequentItems()
        saveData()
        
        print("📝 初期化完了: \(allItemNames.count)個のアイテム名を検出")
    }
    
    // デバッグ用：統計情報を表示
    func printStatistics() {
        print("📊 ItemNameManager統計:")
        print("  - 総アイテム数: \(allItemNames.count)")
        print("  - 最近使用: \(recentItemNames.count)")
        print("  - 頻度上位5位:")
        for (index, item) in frequentItemNames.prefix(5).enumerated() {
            print("    \(index + 1). \(item.name) (\(item.count)回)")
        }
    }
}