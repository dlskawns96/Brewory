//
//  DetailView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import SwiftUI

struct DetailView: View {
    let record: CoffeeRecord
    @ObservedObject var store: CoffeeRecordStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let url = self.record.imageURL,
                   let image = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.bottom, 4)
                }

                // Bean Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bean Info")
                        .font(.headline)
                        .bold()
                        .padding(.bottom, 2)
                    labeledText("Bean", self.record.beanName ?? "")
                    labeledText("Water Temp", String(format: "%.1f℃", self.record.waterTemp ?? 0.0))
                    labeledText("Bean Amount", String(format: "%.1fg", self.record.beanAmount ?? 0.0))
                    labeledText("Water Amount", String(format: "%.1fml", self.record.waterAmount ?? 0.0))
                    labeledText("Brew Time", String(format: "%.0f sec", self.record.brewTime ?? 0.0))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

                // Flavor Notes Section
                if !self.record.flavorNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flavor Notes")
                            .font(.headline)
                            .bold()
                        Text(self.record.flavorNotes.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                // Tasting Notes Section
                if let notes = self.record.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tasting Notes")
                            .font(.headline)
                            .bold()
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                // Rating Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.headline)
                        .bold()
                    Text("\(self.record.rating ?? 0) / 5")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

                Spacer(minLength: 20)

                Button(role: .destructive) {
                    self.store.delete(self.record)
                    self.dismiss()
                } label: {
                    Text("Delete Record")
                        .frame(maxWidth: .infinity)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Brew Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper for labeled rows with visual hierarchy
    private func labeledText(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let store = CoffeeRecordStore()
    let sampleRecord = CoffeeRecord(
        beanName: "Preview Beans",
        beanAmount: 18.0,
        waterTemp: 92.0,
        waterAmount: 250.0,
        brewTime: 180.0,
        flavorNotes: ["Citrus", "Floral"],
        notes: "Bright and juicy cup with floral aroma.",
        rating: 4
    )
    
    return DetailView(record: sampleRecord, store: store)
}

