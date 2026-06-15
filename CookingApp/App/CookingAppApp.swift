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
            HomeView()
        }
        .modelContainer(for: Recipe.self)
    }
}
