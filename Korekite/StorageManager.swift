import Foundation

class StorageManager: ObservableObject {
    @Published var outfits: [Outfit] = []
    private let outfitsKey = "outfits"
    
    init() {
        loadOutfits()
    }
    
    func saveOutfits() {
        if let encoded = try? JSONEncoder().encode(outfits) {
            UserDefaults.standard.set(encoded, forKey: outfitsKey)
            objectWillChange.send()
        }
    }
    
    func loadOutfits() {
        if let data = UserDefaults.standard.data(forKey: outfitsKey),
           let decoded = try? JSONDecoder().decode([Outfit].self, from: data) {
            outfits = decoded
            objectWillChange.send()
        }
    }
    
    func addOutfit(_ item: Outfit) {
        outfits.append(item)
        saveOutfits()
    }
    
    func updateOutfit(_ item: Outfit) {
        if let index = outfits.firstIndex(where: { $0.id == item.id }) {
            outfits[index] = item
            saveOutfits()
        }
    }
    
    func deleteOutfit(_ item: Outfit) {
        outfits.removeAll { $0.id == item.id }
        saveOutfits()
    }
} 