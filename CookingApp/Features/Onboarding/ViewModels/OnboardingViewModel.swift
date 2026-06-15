//
//  OnboardingViewModel.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}
