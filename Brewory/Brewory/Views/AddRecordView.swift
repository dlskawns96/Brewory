//
//  AddRecordView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import SwiftUI
import PhotosUI

struct AddRecordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var store: CoffeeRecordStore
    
    // Inputs
    @State private var beanName: String = ""
    @State private var waterTemp: Double = 90.0
    @State private var beanAmount: Double = 20.0
    @State private var waterAmount: Double = 300.0
    @State private var brewTime: Double = 180.0
    @State private var flavorNotes: String = ""
    @State private var notes: String = ""
    @State private var rating: Int = 0
    
    // image
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Bean Info")) {
                    TextField("Bean Name", text: self.$beanName)
                    Stepper {
                        HStack {
                            Text("Water Temp")
                            Spacer()
                            Text("\(self.waterTemp, specifier: "%.1f")°C")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                    } onIncrement: {
                        self.waterTemp += 0.5
                    } onDecrement: {
                        self.waterTemp -= 0.5
                    }
                    Stepper {
                        HStack {
                            Text("Bean Amount")
                            Spacer()
                            Text("\(self.beanAmount, specifier: "%.1f")g")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                    } onIncrement: {
                        self.beanAmount += 0.5
                    } onDecrement: {
                        self.beanAmount -= 0.5
                    }
                    Stepper {
                        HStack {
                            Text("Water Amount")
                            Spacer()
                            Text("\(self.waterAmount, specifier: "%.1f")ml")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                    } onIncrement: {
                        self.waterAmount += 5
                    } onDecrement: {
                        self.waterAmount -= 5
                    }
                    Stepper {
                        HStack {
                            Text("Brew Time")
                            Spacer()
                            Text("\(self.brewTime, specifier: "%.0f")sec")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                    } onIncrement: {
                        self.brewTime += 1
                    } onDecrement: {
                        self.brewTime -= 1
                    }
                }
                
                Section(header: Text("Tasting")) {
                    TextField("Flavor Notes (comma - separated)", text: self.$flavorNotes)
                    TextEditor(text: self.$notes)
                        .frame(height: 100.0)
                    Stepper(value: self.$rating, in: 0...5) {
                        Text("Rating: \(self.rating)/5")
                    }
                }
                
                Section(header: Text("Photo")) {
                    PhotosPicker("Select a Photo", selection: self.$selectedItem, matching: .images)
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150.0)
                    }
                }
                
                Button("Save") {
                    let record = CoffeeRecord(
                        beanName: self.beanName,
                        beanAmount: self.beanAmount,
                        waterTemp: self.waterTemp,
                        waterAmount: self.waterAmount,
                        brewTime: self.brewTime,
                        flavorNotes: self.flavorNotes.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                        notes: self.notes,
                        rating: self.rating
                    )
                    self.store.add(record, image: self.selectedImage)
                    self.dismiss()
                }
                .disabled(self.beanName.isEmpty)
            }
            .navigationTitle("New Brew")
            .onChange(of: self.selectedItem) {
                guard let selectedItem else { return }
                Task {
                    if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            self.selectedImage = image
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let store = CoffeeRecordStore()
    let sampleRecord = CoffeeRecord(
        beanName: "Sample Beans",
        beanAmount: 18.0,
        waterTemp: 91.5,
        waterAmount: 300.0,
        brewTime: 180.0,
        flavorNotes: ["Citrus", "Floral"],
        notes: "Bright and clean cup.",
        rating: 4
    )
    store.add(sampleRecord, image: nil)
    
    return AddRecordView(store: store)
}
