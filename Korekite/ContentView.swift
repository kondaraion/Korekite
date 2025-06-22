//
//  ContentView.swift
//  Korekite
//
//  Created by 国米宏司 on 2025/04/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var categoryManager = CategoryManager()
    @StateObject private var storageManager = StorageManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()
    @AppStorage("selectedCategory") private var selectedCategory: String?
    @State private var showingAddClothing = false
    
    // 2列のグリッドレイアウト
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var filteredItems: [Outfit] {
        if let category = selectedCategory, !category.isEmpty {
            return storageManager.outfits.filter { $0.category == category }
        }
        return storageManager.outfits
    }
    
    var recommendedItems: [Outfit] {
        guard let weatherInfo = weatherService.weatherInfo else {
            return []
        }
        return storageManager.outfits.filter { $0.category == weatherInfo.recommendedCategory }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 天気情報とおすすめコーディネート
                if let weatherInfo = weatherService.weatherInfo {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(weatherInfo.temperature))°C")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("\(Int(weatherInfo.tempMin))°C - \(Int(weatherInfo.tempMax))°C")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(weatherInfo.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("おすすめ: \(weatherInfo.recommendedCategory)")
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        if !recommendedItems.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recommendedItems.prefix(5)) { item in
                                        NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: categoryManager, storageManager: storageManager)) {
                                            item.image
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(8)
                                                .clipped()
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "すべて", isSelected: selectedCategory == nil || selectedCategory?.isEmpty == true) {
                            selectedCategory = nil
                        }
                        
                        ForEach(categoryManager.categories, id: \.self) { category in
                            CategoryButton(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: OutfitDetailView(outfit: binding(for: item), categoryManager: categoryManager, storageManager: storageManager)) {
                                item.image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: UIScreen.main.bounds.width / 2) // 画面幅の半分のサイズに設定
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("今日はこれ着る？")
            .navigationBarItems(trailing: Button(action: {
                showingAddClothing = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddClothing) {
                AddOutfitView(categoryManager: categoryManager, storageManager: storageManager)
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.location) { location in
                if let location = location {
                    weatherService.fetchWeather(for: location)
                }
            }
        }
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

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    ContentView()
}

