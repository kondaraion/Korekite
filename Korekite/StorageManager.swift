import Foundation

class StorageManager: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    private let clothingItemsKey = "clothingItems"
    
    init() {
        loadClothingItems()
    }
    
    func saveClothingItems() {
        if let encoded = try? JSONEncoder().encode(clothingItems) {
            UserDefaults.standard.set(encoded, forKey: clothingItemsKey)
            objectWillChange.send()
        }
    }
    
    func loadClothingItems() {
        if let data = UserDefaults.standard.data(forKey: clothingItemsKey),
           let decoded = try? JSONDecoder().decode([ClothingItem].self, from: data) {
            clothingItems = decoded
            objectWillChange.send()
        }
    }
    
    func addClothingItem(_ item: ClothingItem) {
        clothingItems.append(item)
        saveClothingItems()
    }
    
    func updateClothingItem(_ item: ClothingItem) {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems[index] = item
            saveClothingItems()
        }
    }
    
    func deleteClothingItem(_ item: ClothingItem) {
        clothingItems.removeAll { $0.id == item.id }
        saveClothingItems()
    }
} 