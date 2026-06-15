//
//  InstructionHelperCompleteViewModel.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import Foundation
import Combine

class InstructionHelperCompleteViewModel: ObservableObject {
    let recipe: Recipe
    var onGoToHome: (() -> Void)?
    
    init(recipe: Recipe, onGoToHome: (() -> Void)? = nil) {
        self.recipe = recipe
        self.onGoToHome = onGoToHome
    }
    
    func finishCooking() {
        if let onGoToHome = onGoToHome {
            onGoToHome()
        } else {
            NotificationCenter.default.post(name: Notification.Name("PopToRoot"), object: nil)
        }
    }
}
