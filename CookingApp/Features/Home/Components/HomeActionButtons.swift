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
    
    let importRecipeTip = ToolTip(tipTitle: "Ambil Resep dari Web", tipSubtitle: "Tempel link resep pilihanmu di sini. Kami akan menyusun bahan dan langkah masaknya secara otomatis.", iconName: "link.badge.plus", buttonTitle: "")
    
    var body: some View {
        HStack() {
            AddRecipeButton(
                isManual: false,
                titleButton: "Import Resep",
                descriptionButton: "Tambahkan resep dari link website",
                action: {
                    if onboardingStep == 0 {
                        onboardingStep = 1
                    }
                    viewModel.isShowingImportSheet = true
                }
            )
            .trackGlobalFrame($buttonFrame)
            .conditionalPopoverTip(onboardingStep == 0, tip: importRecipeTip, arrowEdge: .top)
            
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
