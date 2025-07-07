//
//  HomeView.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var store = CoffeeRecordStore()
    @State private var showAddView = false

    var body: some View {
        TabView {
            NavigationStack {
                RecordListView(store: self.store)
            }
            .tabItem {
                Label("Records", systemImage: "list.bullet")
            }

            NavigationStack {
                AddRecordView(store: self.store)
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle")
            }

            NavigationStack {
                BrewingTimerView(steps: [])
            }
            .tabItem {
                Label("Timer", systemImage: "timer")
            }
        }
    }
}

#Preview {
    HomeView()
}
