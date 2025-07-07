//
//  BrewingPlanEditorView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 6/2/25.
//

import SwiftUI

struct BrewingPlanEditorView: View {
    @EnvironmentObject var store: BrewingRecipeStore
    @State private var steps: [PourStep] = []
    @State private var beanAmount: Double = 0
    @State private var waterAmount: Double = 0
    @State private var isNavigatingToTimer = false
    @State private var isShowingSummary = false
    @State private var isNavigatingToSaveRecord = false
    @State private var completedRecord: CoffeeRecord?
    @State private var showingSaveConfirmation = false
    @State private var recipeName: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recipe Name")
                    TextField("Enter name", text: self.$recipeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Bean Amount")
                        Spacer()
                        HStack(spacing: 4) {
                            TextField("g", value: self.$beanAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Total Water")
                        Spacer()
                        HStack(spacing: 4) {
                            TextField("g", value: self.$waterAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Time (s)")
                            .frame(width: 80, alignment: .leading)
                        Text("Target Water (g)")
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    
                    Text("Target Water is the cumulative amount by each step")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ForEach(self.steps.indices, id: \.self) { index in
                        HStack {
                            HStack(spacing: 4) {
                                TextField("Time", value: self.$steps[index].time, format: .number)
                                    .keyboardType(.numberPad)
                                Text("s")
                            }
                            .frame(width: 80)

                            Spacer()

                            HStack(spacing: 4) {
                                TextField("Water", value: self.$steps[index].targetWater, format: .number)
                                    .keyboardType(.numberPad)
                                    .frame(width: 100)
                                Text("g")
                            }

                            Spacer()

                            Button(role: .destructive) {
                                self.steps.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Edit Brewing Plan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: self.$isNavigatingToTimer) {
            BrewingTimerView(steps: self.steps)
        }
        .navigationDestination(isPresented: self.$isShowingSummary) {
            if let record = self.completedRecord {
                VStack(spacing: 24) {
                    Text("Extraction Complete")
                        .font(.title)
                        .bold()

                    Text("Time: \(record.brewTime != nil ? "\(Int(record.brewTime!)) s" : "0 s")")
                        .font(.title3)
                    if let last = self.steps.last {
                        Text("Total Water: \(Int(last.targetWater))g")
                            .font(.title3)
                    }

                    Button("Save Record") {
                        self.isNavigatingToSaveRecord = true
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: self.$isNavigatingToSaveRecord) {
                    if let record = self.completedRecord {
                        SaveRecordView(record: record)
                    }
                }
            }
        }
        VStack(spacing: 12) {
            Button("+ Add Step") {
                let lastTime = self.steps.last?.time ?? 0
                let lastWater = self.steps.last?.targetWater ?? 0
                self.steps.append(PourStep(time: lastTime + 10, targetWater: lastWater + 50))
            }

            Button {
                self.showingSaveConfirmation = true
            } label: {
                Text("Save Recipe")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .confirmationDialog("Start timer after saving?", isPresented: self.$showingSaveConfirmation, titleVisibility: .visible) {
                Button("Save and Start Timer") {
                    let recipe = BrewingRecipe(
                        id: UUID(),
                        name: self.recipeName.isEmpty ? "Untitled" : self.recipeName,
                        beanAmount: self.beanAmount,
                        waterAmount: self.waterAmount,
                        steps: self.steps
                    )
                    self.store.add(recipe)
                    self.isNavigatingToTimer = true
                }

                Button("Just Save") {
                    let recipe = BrewingRecipe(
                        id: UUID(),
                        name: self.recipeName.isEmpty ? "Untitled" : self.recipeName,
                        beanAmount: self.beanAmount,
                        waterAmount: self.waterAmount,
                        steps: self.steps
                    )
                    self.store.add(recipe)
                }

                Button("Cancel", role: .cancel) {}
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    NavigationStack {
        BrewingPlanEditorView()
    }
}
