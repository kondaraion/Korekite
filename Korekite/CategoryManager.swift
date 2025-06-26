import Foundation

class CategoryManager: ObservableObject {
    @Published var categories: [String] = ["極寒", "寒い", "涼しい", "暖かい", "暑い", "猛暑"] {
        didSet {
            saveCategories()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let categoriesKey = "SavedCategories"
    
    init() {
        loadCategories()
    }
    
    func addCategory(_ category: String) {
        if !categories.contains(category) {
            categories.append(category)
        }
    }
    
    func removeCategory(_ category: String) {
        categories.removeAll { $0 == category }
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        var categories = self.categories
        categories.move(fromOffsets: source, toOffset: destination)
        self.categories = categories
    }
    
    // MARK: - Persistence
    
    private func saveCategories() {
        userDefaults.set(categories, forKey: categoriesKey)
    }
    
    private func loadCategories() {
        if let savedCategories = userDefaults.array(forKey: categoriesKey) as? [String], !savedCategories.isEmpty {
            categories = savedCategories
        }
        // デフォルトカテゴリは初期化時に設定されているので、保存されたデータがない場合は既存の値を使用
    }
} 