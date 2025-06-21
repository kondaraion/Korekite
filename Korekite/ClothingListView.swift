import SwiftUI

struct ClothingListView: View {
    @ObservedObject var storageManager: StorageManager
    @State private var selectedCategory: String = "すべて"
    @State private var searchText: String = ""
    
    private var filteredClothingItems: [ClothingItem] {
        let items = storageManager.clothingItems
        
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
        List(filteredClothingItems) { item in
            NavigationLink(destination: ClothingDetailView(clothing: binding(for: item), categoryManager: CategoryManager(), storageManager: storageManager)) {
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
        .navigationTitle("服一覧")
    }
    
    private func binding(for item: ClothingItem) -> Binding<ClothingItem> {
        Binding(
            get: {
                if let index = storageManager.clothingItems.firstIndex(where: { $0.id == item.id }) {
                    return storageManager.clothingItems[index]
                }
                return item
            },
            set: { newValue in
                if let index = storageManager.clothingItems.firstIndex(where: { $0.id == newValue.id }) {
                    storageManager.clothingItems[index] = newValue
                    storageManager.saveClothingItems()
                }
            }
        )
    }
} 
