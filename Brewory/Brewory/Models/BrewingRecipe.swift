//
//  BrewingRecipe.swift
//  Brewory
//
//  Created by Nam Jun Lee on 7/6/25.
//

import Foundation

struct BrewingRecipe: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var beanAmount: Double
    var waterAmount: Double
    var steps: [PourStep]
}
