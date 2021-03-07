//
//  ImagePicker.swift
//  WhenGameRelease
//
//  Created by Андрей on 02.03.2021.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @State private var inputImage: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                let widthRatio = 100 / uiImage.size.width
                let heightRatio = 100 / uiImage.size.height
                let scaleFactor = min(widthRatio, heightRatio)
                
                // Compute the new image size that preserves aspect ratio
                let scaledImageSize = CGSize(
                    width: uiImage.size.width * scaleFactor,
                    height: uiImage.size.height * scaleFactor
                )
                
                // Draw and return the resized UIImage
                let renderer = UIGraphicsImageRenderer(
                    size: scaledImageSize
                )
                
                let scaledImage = renderer.image { _ in
                    uiImage.draw(in: CGRect(
                        origin: .zero,
                        size: scaledImageSize
                    ))
                }
                parent.image = scaledImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
