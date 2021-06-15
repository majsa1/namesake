//
//  ImageHandler.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI

class ImageHandler {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func selectImage(inputImage: UIImage?) -> Image? {
        if let img = inputImage {
            return Image(uiImage: img)
        }
        return nil
    }
    
    func loadImage(for person: Person) -> Image? {
        let filename = getDocumentsDirectory().appendingPathComponent(person.unwrappedId)

        do {
            let loaded = try Data(contentsOf: filename)
            if let outputImage = UIImage(data: loaded) {
                return Image(uiImage: outputImage)
            }
        } catch {
            print("Unable to load saved image.")
        }
        return nil
    }
    
    func saveImage(inputImage: UIImage?, for person: Person) {
        let filename = getDocumentsDirectory().appendingPathComponent(person.unwrappedId)
        
        if let data = inputImage?.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } else {
            print("Failed to save image")
        }
    }
    
    func deleteImage(person: Person) {
        let filename = getDocumentsDirectory().appendingPathComponent(person.unwrappedId)
        
        if let _ = try? FileManager.default.removeItem(at: filename) {
        } else {
            print("Unable to delete image")
        }
    }
}
