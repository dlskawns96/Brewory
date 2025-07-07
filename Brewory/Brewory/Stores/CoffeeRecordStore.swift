//
//  CoffeeRecordStore.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import Foundation
import SwiftUI

final class CoffeeRecordStore: ObservableObject {
    @Published private(set) var records: [CoffeeRecord] = []
    
    private let fileName = "coffee_records.json"
    
    private var fileURL: URL {
        FileManager.documentsDirectory.appendingPathComponent(self.fileName)
    }
    
    init() {
        self.load()
    }

    /// Testing/preview initializer for injecting mock data
    init(records: [CoffeeRecord]) {
        self.records = records
    }
    
    func add(_ record: CoffeeRecord, image: UIImage?) {
        var newRecord = record
        if let image {
            let name = "\(record.id).jpg"
            newRecord.imageFileName = name
            saveImage(image, with: name)
        }
        self.records.append(newRecord)
        self.save()
    }
    
    func delete(_ record: CoffeeRecord) {
        self.records.removeAll { $0.id == record.id }
        if let name = record.imageFileName {
            self.deleteImage(named: name)
        }
        self.save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Save error: \(error)")
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([CoffeeRecord].self, from: data)
        } catch {
            print("Load error: \(error)")
            records = []
        }
    }
    
    private func saveImage(_ image: UIImage, with name: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.documentsDirectory.appendingPathComponent(name)
        try? data.write(to: url)
    }
    
    private func deleteImage(named name: String) {
        let url = FileManager.documentsDirectory.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
    }}
