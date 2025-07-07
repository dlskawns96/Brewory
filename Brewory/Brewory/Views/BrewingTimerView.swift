//
//  BrewingTimerView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import SwiftUI

struct BrewingTimerView: View {
    @StateObject private var recipeStore = BrewingRecipeStore()
    @State private var selectedRecipe: BrewingRecipe?
    @State private var isShowingRecipeList = false
    @State private var steps: [PourStep]

    @State private var startTime: Date?
    @State private var currentTime: TimeInterval = 0
    @State private var isFinished = false
    @State private var hasStarted = false
    @State private var isShowingSummary = false
    @State private var isNavigatingToSaveRecord = false
    @State private var completedRecord: CoffeeRecord?
    @Environment(\.dismiss) private var dismiss

    // Each PourStep represents the target water amount to reach by the *next* step's time.
    // The current step is the one whose time is <= currentTime, and which is not the last step.
    private var currentStep: PourStep? {
        guard let index = self.steps.firstIndex(where: { self.currentTime < $0.time }) else {
            return self.steps.last
        }
        if index > 0 {
            return self.steps[index - 1]
        }
        return nil
    }

    private var nextStep: PourStep? {
        self.steps.first(where: { self.currentTime < $0.time })
    }

    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 0.2, on: .main, in: .common)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Text(self.formattedTime(self.currentTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(self.steps.enumerated()), id: \.offset) { index, step in
                        let isCurrent = self.currentStep == step
                        let isNext = self.nextStep == step

                        HStack {
                            Text("\(step.time, specifier: "%.0f")s")
                                .frame(width: 60, alignment: .center)
                            Text("→")
                                .frame(minWidth: 20, alignment: .center)
                            Text("\(Int(step.targetWater))g")
                                .frame(width: 60, alignment: .center)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 56)
                        .background(isCurrent ? Color.green.opacity(0.3) :
                                    isNext ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                        .font(.title3)
                    }
                }

                if self.isFinished {
                    Text("✓ Extraction Complete")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.top)

                    if let lastStep = self.steps.last {
                        Text("Total Water: \(Int(lastStep.targetWater))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let step = self.currentStep {
                    Text("→ Pour up to \(Int(step.targetWater))g")
                        .font(.title2)
                        .foregroundColor(.green)
                        .padding(.top)
                }

                if let next = self.nextStep {
                    Text("Next step at \(Int(next.time))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !self.hasStarted {
                    Button("Start") {
                        self.startTime = Date()
                        self.hasStarted = true
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                } else {
                    Button("Done") {
                        self.isFinished = true

                        let finalRecord = CoffeeRecord(
                            date: Date(),
                            beanName: nil,
                            beanAmount: nil,
                            waterTemp: nil,
                            waterAmount: nil,
                            brewTime: self.currentTime,
                            flavorNotes: [],
                            notes: nil,
                            rating: nil,
                            imageFileName: nil,
                            pourSteps: nil
                        )
                        self.completedRecord = finalRecord
                        self.isShowingSummary = true
                    }
                    .padding()
                    .foregroundColor(.primary.opacity(0.7))
                }
            }
            .padding()
        }
        .onAppear {
            if let last = self.recipeStore.loadLastSelectedRecipe() {
                self.selectedRecipe = last
                self.steps = last.steps
                self.hasStarted = false
                self.currentTime = 0
                self.isFinished = false
                self.startTime = nil
            }
        }
        .onReceive(self.timer.autoconnect()) { _ in
            guard self.hasStarted, !self.isFinished, let start = self.startTime else { return }
            self.currentTime = Date().timeIntervalSince(start)

            // Only set isFinished if steps exist and currentTime >= last step's time
            // Removed to allow timer to run indefinitely until user taps "Done"
            /*
            if !self.steps.isEmpty, self.currentTime >= self.steps.last!.time {
                self.isFinished = true
            }
            */
        }
        .navigationDestination(isPresented: self.$isShowingSummary) {
            if let record = self.completedRecord {
                VStack(spacing: 24) {
                    Text("Extraction Complete")
                        .font(.title)
                        .bold()

                    Text("Time: \(self.formattedTime(record.brewTime ?? 0))")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isShowingRecipeList = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .imageScale(.large)
                }
            }
        }
        .navigationDestination(isPresented: self.$isShowingRecipeList) {
            BrewingRecipeListView(store: self.recipeStore) { recipe in
                self.selectedRecipe = recipe
                self.steps = recipe.steps
                self.hasStarted = false
                self.currentTime = 0
                self.isFinished = false
                self.startTime = nil
                self.isShowingRecipeList = false
            }
        }
        .onDisappear {
            self.hasStarted = false
            self.startTime = nil
            self.isFinished = false
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    init(steps: [PourStep]) {
        _steps = State(initialValue: steps)
    }
}

#Preview {
    let sampleSteps = [
        PourStep(time: 0, targetWater: 60),    // 0초부터 60g까지 부으라는 의미
        PourStep(time: 10, targetWater: 120),
        PourStep(time: 20, targetWater: 200)
    ]
    return BrewingTimerView(steps: sampleSteps)
}
