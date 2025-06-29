import SwiftUI
import UIKit
import AVFoundation

struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @State private var permissionDenied = false
    @Environment(\.presentationMode) var presentationMode
    
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        // 指定されたソースタイプを使用
        var finalSourceType = sourceType
        
        // カメラの場合のみ権限をチェック
        if sourceType == .camera {
            let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraAuthStatus {
            case .authorized:
                // 権限あり、カメラを使用
                finalSourceType = .camera
            case .notDetermined:
                // 権限未確認の場合、権限リクエストを送信
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if !granted {
                            self.permissionDenied = true
                        }
                    }
                }
                finalSourceType = .camera
            case .denied, .restricted:
                // 権限拒否、ユーザーに通知してフォトライブラリにフォールバック
                DispatchQueue.main.async {
                    self.permissionDenied = true
                }
                finalSourceType = .photoLibrary
            @unknown default:
                finalSourceType = .photoLibrary
            }
        }
        // フォトライブラリの場合はそのまま使用
        
        // ソースタイプが利用可能かチェック
        if !UIImagePickerController.isSourceTypeAvailable(finalSourceType) {
            finalSourceType = .photoLibrary
        }
        
        picker.sourceType = finalSourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        
        // カメラの場合はスクエア撮影を推奨
        if picker.sourceType == .camera {
            picker.cameraViewTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraImagePicker
        
        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage.squareCropped()
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage.squareCropped()
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

extension UIImage {
    func squareCropped() -> UIImage? {
        let size = min(self.size.width, self.size.height)
        let origin = CGPoint(
            x: (self.size.width - size) / 2,
            y: (self.size.height - size) / 2
        )
        
        guard let cgImage = self.cgImage?.cropping(to: CGRect(
            origin: origin,
            size: CGSize(width: size, height: size)
        )) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return jpegData(compressionQuality: quality)
    }
}