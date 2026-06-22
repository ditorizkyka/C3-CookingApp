//
//  HomeActionButtons.swift
//  CookingApp
//

import SwiftUI
import TipKit

struct HomeActionButtons: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var onboardingStep: Int
    @Binding var buttonFrame: CGRect
    
    
    var body: some View {
        HStack() {
            AddRecipeButton(
                isManual: false,
                titleButton: "Import Resep",
                descriptionButton: "Tambahkan resep dari link website",
                action: {
                    if onboardingStep == 0 {
                        updateOnboarding(to: 1)
                    }
                    viewModel.isShowingImportSheet = true
                }
            )
            .trackGlobalFrame($buttonFrame)
            .conditionalTip(onboardingStep == 0, tip: ImportRecipeTip(), arrowEdge: .top)
            
            AddRecipeButton(
                isManual: true,
                titleButton: "Tulis Resep",
                descriptionButton: "Buat dan simpan resepmu",
                action: {
                    viewModel.navigateToManual = true
                }
            )
        }
        .padding(.horizontal)
    }
}
