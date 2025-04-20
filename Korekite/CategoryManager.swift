import Foundation

class CategoryManager: ObservableObject {
    @Published var categories: [String] = ["極寒", "寒い", "涼しい", "暖かい", "暑い", "猛暑"]
    
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
} 