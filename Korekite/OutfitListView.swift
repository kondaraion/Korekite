import SwiftUI

struct OutfitListView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var itemNameManager: ItemNameManager
    @State private var selectedCategory: String = "すべて"
    @State private var searchText: String = ""
    
    private var filteredOutfits: [Outfit] {
        let items = storageManager.outfits
        
        // カテゴリーフィルター
        let categoryFiltered = selectedCategory == "すべて" ? items : items.filter { $0.category == selectedCategory }
        
        // 検索フィルター
        let searchFiltered = searchText.isEmpty ? categoryFiltered : categoryFiltered.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText) ||
            item.category.localizedCaseInsensitiveContains(searchText) ||
            item.memo.localizedCaseInsensitiveContains(searchText)
        }
        
        // 着用日または登録日が最近の順にソート
        return searchFiltered.sorted { item1, item2 in
            let date1 = item1.lastWornDates.max() ?? item1.wearHistory.first ?? Date.distantPast
            let date2 = item2.lastWornDates.max() ?? item2.wearHistory.first ?? Date.distantPast
            return date1 > date2
        }
    }
    
    var body: some View {
        List(filteredOutfits) { item in
            NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: CategoryManager(), storageManager: storageManager, itemNameManager: itemNameManager)) {
                HStack {
                    item.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "検索")
        .navigationTitle("コーディネート一覧")
    }
    
    private func binding(for item: Outfit) -> Binding<Outfit> {
        Binding(
            get: {
                if let index = storageManager.outfits.firstIndex(where: { $0.id == item.id }) {
                    return storageManager.outfits[index]
                }
                return item
            },
            set: { newValue in
                if let index = storageManager.outfits.firstIndex(where: { $0.id == newValue.id }) {
                    storageManager.outfits[index] = newValue
                    storageManager.saveOutfits()
                }
            }
        )
    }
} 
