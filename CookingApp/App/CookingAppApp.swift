//
//  CookingAppApp.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 05/06/26.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct CookingAppApp: App {
    init() {
        #if DEBUG
        // try? Tips.resetDatastore()
        #endif
        
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ReproRoot()
        }
        .modelContainer(PreviewContainer.shared)
    }
}

// TEMP REPRO
struct ReproRoot: View {
    @Query private var recipes: [Recipe]
    var body: some View {
        NavigationStack {
            if let r = recipes.first(where: { !$0.ingredients.isEmpty }) {
                HomeView()
            } else {
                Text("no data")
            }
        }
    }
}
