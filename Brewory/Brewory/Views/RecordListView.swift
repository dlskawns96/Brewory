//
//  RecordListView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 6/8/25.
//

import SwiftUI

struct RecordListView: View {
    @ObservedObject var store: CoffeeRecordStore

    var body: some View {
        NavigationStack {
            if store.records.isEmpty {
                VStack(spacing: 16) {
                    Text("No records yet.")
                        .foregroundColor(.secondary)

                    NavigationLink {
                        AddRecordView(store: store)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add your first record")
                        }
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(self.store.records.sorted(by: { $0.date > $1.date })) { record in
                        NavigationLink {
                            DetailView(record: record, store: self.store)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.beanName ?? "Unnamed")
                                    .font(.headline)
                                Text(Self.dateFormatter.string(from: record.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
        }
        .navigationTitle("My Records")
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

#Preview {
    let sampleStore = CoffeeRecordStore(records: [
        CoffeeRecord(
            date: Date(),
            beanName: "Ethiopia",
            beanAmount: 15,
            waterTemp: 92,
            waterAmount: 250,
            brewTime: 120,
            flavorNotes: ["Floral", "Bright"],
            notes: "Very clean and aromatic.",
            rating: 4,
            imageFileName: nil,
            pourSteps: []
        ),
        CoffeeRecord(
            date: Date().addingTimeInterval(-3600),
            beanName: "Kenya AA",
            beanAmount: 16,
            waterTemp: 93,
            waterAmount: 260,
            brewTime: 130,
            flavorNotes: ["Fruity", "Bold"],
            notes: "Nice acidity and body.",
            rating: 5,
            imageFileName: nil,
            pourSteps: []
        )
    ])
    
    return RecordListView(store: sampleStore)
}
