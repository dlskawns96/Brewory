//
//  BrewingRecipeListView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 7/6/25.
//

import SwiftUI

struct BrewingRecipeListView: View {
    @ObservedObject var store: BrewingRecipeStore
    var onSelect: (BrewingRecipe) -> Void
    
    var body: some View {
        Group {
            if store.recipes.isEmpty {
                VStack(spacing: 16) {
                    Text("No recipes yet.")
                        .foregroundColor(.secondary)
                    NavigationLink("Add Recipe") {
                        BrewingPlanEditorView().environmentObject(self.store)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.recipes) { recipe in
                        Button {
                            self.store.saveLastSelectedRecipe(recipe)
                            self.onSelect(recipe)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(recipe.name)
                                    .font(.headline)
                                HStack {
                                    Text("Bean: \(Int(recipe.beanAmount))g")
                                    Text("Water: \(Int(recipe.waterAmount))g")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let recipe = store.recipes[index]
                            store.delete(recipe)
                        }
                    }
                }
            }
        }
        .navigationTitle("Brewing Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: BrewingPlanEditorView().environmentObject(self.store)) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrewingRecipeListView(
            store: BrewingRecipeStore(),
            onSelect: { _ in }
        )
    }
}
