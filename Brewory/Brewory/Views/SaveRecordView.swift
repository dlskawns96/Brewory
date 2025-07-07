//
//  SaveRecordView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 6/8/25.
//

import SwiftUI

struct SaveRecordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var record: CoffeeRecord
    @State private var beanName: String = ""
    @State private var waterTemp: String = ""
    @State private var notes: String = ""
    @State private var rating: Int = 3
    @State private var newFlavorNote: String = ""

    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingUIImagePicker = false

    init(record: CoffeeRecord) {
        _record = State(initialValue: record)
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    if let uiImage = self.selectedImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .onTapGesture {
                                self.isShowingImagePicker = true
                            }

                        Button("Change Image") {
                            self.isShowingImagePicker = true
                        }
                        .font(.caption)
                    } else {
                        Button("Add Image") {
                            self.isShowingImagePicker = true
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .actionSheet(isPresented: self.$isShowingImagePicker) {
                ActionSheet(
                    title: Text("Select Image"),
                    buttons: [
                        .default(Text("Camera")) {
                            self.imagePickerSource = .camera
                            self.presentImagePicker()
                        },
                        .default(Text("Photo Library")) {
                            self.imagePickerSource = .photoLibrary
                            self.presentImagePicker()
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: self.$showingUIImagePicker) {
                ImagePicker(sourceType: self.imagePickerSource, image: self.$selectedImage)
            }

            Section(header: Text("Bean Info")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. Ethiopia Yirgacheffe", text: self.$beanName)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bean Amount (g)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. 15", text: Binding(
                        get: { self.record.beanAmount.map { String($0) } ?? "" },
                        set: { self.record.beanAmount = Double($0) }
                    ))
                    .keyboardType(.decimalPad)
                }
            }

            Section(header: Text("Brew Details")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water Temperature (°C)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. 93", text: self.$waterTemp)
                        .keyboardType(.decimalPad)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water Amount (g)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. 250", text: Binding(
                        get: { self.record.waterAmount.map { String($0) } ?? "" },
                        set: { self.record.waterAmount = Double($0) }
                    ))
                    .keyboardType(.decimalPad)
                }
                Text("Brew Time: \(self.record.brewTime.map { Int($0) } ?? 0) sec")
            }

            Section(header: Text("Flavor Notes")) {
                ForEach(self.record.flavorNotes, id: \.self) { note in
                    Text("• \(note)")
                }
                HStack {
                    TextField("Add note", text: self.$newFlavorNote)
                    Button(action: {
                        let trimmed = self.newFlavorNote.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            self.record.flavorNotes.append(trimmed)
                            self.newFlavorNote = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }

            Section(header: Text("Notes")) {
                TextEditor(text: self.$notes)
                    .frame(height: 100)
            }

            Section(header: Text("Rating")) {
                Stepper(value: self.$rating, in: 1...5) {
                    Text("Rating: \(self.rating)")
                }
            }

            Section(header: Text("Image")) {
                if let fileName = self.record.imageFileName {
                    Text(fileName)
                } else {
                    Text("No image attached.")
                }
            }

            Section(header: Text("Pour Steps")) {
                if let steps = self.record.pourSteps {
                    ForEach(steps) { step in
                        Text("\(Int(step.time))s → \(Int(step.targetWater))g")
                    }
                } else {
                    Text("No pour steps.")
                }
            }

            Button("Save") {
                self.record.beanName = self.beanName
                self.record.waterTemp = Double(self.waterTemp)
                self.record.notes = self.notes
                self.record.rating = self.rating
                // Implement image saving logic if needed
                self.dismiss()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Save Record")
        .onAppear {
            self.beanName = self.record.beanName ?? ""
            self.waterTemp = self.record.waterTemp.map { String($0) } ?? ""
            self.notes = self.record.notes ?? ""
            self.rating = self.record.rating ?? 3
        }
    }

    private func presentImagePicker() {
        self.showingUIImagePicker = true
    }
}

#Preview {
    let sampleRecord = CoffeeRecord(
        date: Date(),
        beanName: "Kenya AA",
        beanAmount: 15.0,
        waterTemp: 92.0,
        waterAmount: 250.0,
        brewTime: 120.0,
        flavorNotes: ["Fruity", "Citrus"],
        notes: "Bright and clean taste.",
        rating: 4,
        imageFileName: nil,
        pourSteps: [
            PourStep(time: 0, targetWater: 50),
            PourStep(time: 30, targetWater: 150),
            PourStep(time: 60, targetWater: 250)
        ]
    )
    
    return NavigationStack {
        SaveRecordView(record: sampleRecord)
    }
}
