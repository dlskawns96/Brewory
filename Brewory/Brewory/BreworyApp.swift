//
//  BreworyApp.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/15/25.
//

import SwiftUI

@main
struct BreworyApp: App {
    @StateObject private var store = CoffeeRecordStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
