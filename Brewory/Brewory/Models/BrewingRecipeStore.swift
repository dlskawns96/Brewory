//
//  BrewingRecipeStore.swift
//  Brewory
//
//  Created by Nam Jun Lee on 7/6/25.
//

import Foundation

final class BrewingRecipeStore: ObservableObject {
    @Published private(set) var recipes: [BrewingRecipe] = []
    
    private let userDefaultsKey = "BrewingRecipes"
    
    init() {
        self.load()
    }
    
    func add(_ recipe: BrewingRecipe) {
        self.recipes.append(recipe)
        self.save()
    }
    
    func delete(_ recipe: BrewingRecipe) {
        self.recipes.removeAll { $0.id == recipe.id }
        self.save()
    }
    
    func update(_ recipe: BrewingRecipe) {
        if let index = self.recipes.firstIndex(where: { $0.id == recipe.id }) {
            self.recipes[index] = recipe
            self.save()
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(self.recipes) {
            UserDefaults.standard.set(data, forKey: self.userDefaultsKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: self.userDefaultsKey),
           let saved = try? JSONDecoder().decode([BrewingRecipe].self, from: data) {
            self.recipes = saved
        }
    }
}

extension BrewingRecipeStore {
    private var lastSelectedRecipeKey: String { "lastSelectedRecipeID" }

    func saveLastSelectedRecipe(_ recipe: BrewingRecipe) {
        UserDefaults.standard.set(recipe.id.uuidString, forKey: lastSelectedRecipeKey)
    }

    func loadLastSelectedRecipe() -> BrewingRecipe? {
        guard let idString = UserDefaults.standard.string(forKey: lastSelectedRecipeKey),
              let uuid = UUID(uuidString: idString) else { return nil }
        return recipes.first(where: { $0.id == uuid })
    }
}
