import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct AddOutfitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var weatherService: WeatherService
    
    @State private var itemName: String = ""
    @State private var selectedCategory: String = ""
    @State private var memo: String = ""
    @State private var isReferenceImage: Bool = false
    @State private var showingCategoryPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImageSourceSelection = false
    @State private var showingCameraPicker = false
    @State private var showingPhotoPicker = false
    @State private var capturedImage: UIImage?
    @State private var showingCameraPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("写真")) {
                    HStack {
                        Spacer()
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .cornerRadius(10)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingImageSourceSelection = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        .actionSheet(isPresented: $showingImageSourceSelection) {
                            ActionSheet(title: Text("写真を追加"), buttons: [
                                .default(Text("カメラで撮影")) {
                                    showingCameraPicker = true
                                },
                                .default(Text("ライブラリから選択")) {
                                    showingPhotoPicker = true
                                },
                                .cancel()
                            ])
                        }
                        .sheet(isPresented: $showingCameraPicker) {
                            CameraImagePicker(selectedImage: $capturedImage, sourceType: .camera)
                                .onChange(of: showingCameraPicker) { _, newValue in
                                    if !newValue {
                                        checkCameraPermissionAndShowAlert()
                                    }
                                }
                        }
                        .sheet(isPresented: $showingPhotoPicker) {
                            CameraImagePicker(selectedImage: $capturedImage, sourceType: .photoLibrary)
                        }
                        
                        Spacer()
                    }
                    
                }
                
                Section(header: Text("基本情報")) {
                    HStack {
                        Text("アイテム名")
                        TextField("例: 白いTシャツ", text: $itemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text("カテゴリー")
                            Spacer()
                            Text(selectedCategory.isEmpty ? "選択してください" : selectedCategory)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Text("参考画像")
                        Spacer()
                        Toggle("", isOn: $isReferenceImage)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("メモ")) {
                    TextEditor(text: $memo)
                        .frame(height: 100)
                }
            }
            .navigationTitle("新規コーディネートの追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("追加") {
                    addClothing()
                }
                .disabled(selectedCategory.isEmpty || selectedImageData == nil)
            )
            .sheet(isPresented: $showingCategoryPicker) {
                NavigationView {
                    List(categoryManager.categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            showingCategoryPicker = false
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if category == selectedCategory {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .navigationTitle("カテゴリー選択")
                    .navigationBarItems(trailing: Button("キャンセル") {
                        showingCategoryPicker = false
                    })
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let item = newValue,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImageData = ImageUtils.processForStorage(uiImage)
                    }
                }
            }
            .onChange(of: capturedImage) { oldValue, newValue in
                if let image = newValue {
                    selectedImageData = ImageUtils.processForStorage(image)
                }
            }
        }
        .alert("カメラアクセス許可", isPresented: $showingCameraPermissionAlert) {
            Button("設定を開く") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("カメラを使用するには、設定でカメラへのアクセスを許可してください。")
        }
        .onAppear {
            if selectedCategory.isEmpty {
                selectedCategory = weatherService.weatherInfo?.recommendedCategory ?? ""
            }
        }
    }
    
    private func addClothing() {
        let finalName = itemName.isEmpty ? "名称未設定" : itemName
        var newItem = Outfit(
            name: finalName,
            category: selectedCategory,
            memo: memo,
            isReferenceImage: isReferenceImage
        )
        
        // 画像をファイルとして保存
        if let imageData = selectedImageData,
           let filename = storageManager.saveImage(imageData, for: newItem.id) {
            newItem.imageFilename = filename
        }
        
        storageManager.addOutfit(newItem)
        dismiss()
    }
    
    private func isCameraAvailable() -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return false
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return authStatus == .authorized || authStatus == .notDetermined
    }
    
    private func checkCameraPermissionAndShowAlert() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .denied || authStatus == .restricted {
            showingCameraPermissionAlert = true
        }
    }
} 