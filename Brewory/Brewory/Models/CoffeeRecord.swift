//
//  CoffeeRecord.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/15/25.
//

import Foundation
import SwiftUI

struct CoffeeRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var beanName: String?
    var beanAmount: Double?
    var waterTemp: Double?
    var waterAmount: Double?
    var brewTime: TimeInterval?
    var flavorNotes: [String]
    var notes: String?
    var rating: Int?
    var imageFileName: String?
    var pourSteps: [PourStep]?

    var imageURL: URL? {
        guard let name = imageFileName else { return nil }
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}
