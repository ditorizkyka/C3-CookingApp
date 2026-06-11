//
//  HomeView.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI
import TipKit

struct HomeView: View {
    @State private var searchRecipe: String = ""
    @State private var selectedIndex: Int? = nil
    @State private var allRecipes: [Recipe] = Recipe.dummyRecipes
    
    @State private var navigateToManual = false
    @State private var navigateToDetail = false
    @State private var navigateToLoading = false
    
    @State private var isShowingImportSheet = false
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    
    @State private var buttonFrame: CGRect = .zero
    let importRecipeTip = ToolTip(tipTitle: "Ambil Resep dari Web", tipSubtitle: "Tempel link resep pilihanmu di sini. Kami akan menyusun bahan dan langkah masaknya secara otomatis.", iconName: "link.badge.plus", buttonTitle: "")
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                    
                    // Add Recipe Button
                    HStack() {
                        AddRecipeButton(isManual: false, titleButton: "Import Resep", descriptionButton: "Tambahkan resep dari link website",
                                        action: {
                            if onboardingStep == 0 {
                                onboardingStep = 1
                            }
                            isShowingImportSheet = true
                        })
                        .trackGlobalFrame($buttonFrame)
                        .conditionalPopoverTip(onboardingStep == 0, tip: importRecipeTip, arrowEdge: .top)
                        AddRecipeButton(isManual: true, titleButton: "Tulis Resep", descriptionButton: "Buat dan simpan resepmu",
                                        action: {
                            navigateToManual = true
                            
                        })
                        
                    }
                    .padding(.horizontal)
                    
                    // Recipe Section
                    VStack(spacing: 16) {
                        // Title
                        HStack {
                            Text("Resep")
                                .font(Font.headline)
                                .foregroundStyle(Color.labelLight!)
                            
                            Spacer()
                            
                            NavigationLink {
                                RecipeLibrary()
                            } label: {
                                Text("Lihat Semua")
                                    .font(Font.subheadline)
                                    .foregroundStyle(Color.brandAccent!)
                            }
                        }
                        .padding(.horizontal,14)
                        
                        if !allRecipes.isEmpty {
                            ScrollView {
                                VStack(spacing: -120) {
                                    ForEach(allRecipes.indices, id: \.self) { index in
                                        let isSelected = selectedIndex == index
                                        let recipe = allRecipes[index]
                                        let colors: [Color] = [.recipeCardBronze ?? .orange, .recipeCardCyan ?? .cyan, .recipeCardGreen ?? .green, .recipeCardPurple ?? .purple, .recipeCardRed ?? .red]
                                        let color = colors[index % colors.count]
                                        
                                        RecipeCard(
                                            recipeTitle: recipe.title,
                                            recipeCategoryIcon: "🍲",
                                            recipeImage: "img_test",
                                            recipeColor: color,
                                            recipePortion: recipe.portion,
                                            recipeDuration: recipe.durationInMinutes
                                        )
                                        .zIndex(Double(index))
                                        .brightness(!isSelected ? -Double(allRecipes.count - index) * 0.02 : 0)
                                        .padding(.top, selectedIndex != nil && index == selectedIndex! + 1 ? 160 : 0)
                                        .onTapGesture {
                                            if selectedIndex == index {
                                                navigateToDetail = true
                                            } else {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                                    selectedIndex = index
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                            
                        } else {
                            HomeEmptyStateCard()
                        }
                        
                        Spacer()
                        
                    }
                    .sheet(isPresented: $isShowingImportSheet) {
                        ImportRecipeSheet(onImportFinished: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToLoading = true
                            }
                        })
                        .presentationDetents([.fraction(0.5), .large])
                        .presentationDragIndicator(.visible)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    .frame(maxHeight: .infinity)
            }
            .background(Color.surfaceBrand.ignoresSafeArea())
            .searchable(
                text: $searchRecipe,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Cari resep..."
            )
            .searchDictationBehavior(.inline(activation: .onSelect))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToManual) {
                AddManualRecipeView()
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                DetailRecipeView()
            }
            .navigationDestination(isPresented: $navigateToLoading) {
                LoadingView(text: "Menganalisis resep...", onSave: {
                    navigateToLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToDetail = true
                    }
                })
            }.onTapGesture {
                onboardingStep = 0 // Klik teks judul untuk mereset memori ke 0
            }
        }
        .holeMaskOverlay(isActive: Binding(get: { onboardingStep == 0 }, set: { if !$0 && onboardingStep == 0 { onboardingStep = 1 } }), holeFrame: buttonFrame, cornerRadius: Radius.small)
    }
}

#Preview {
    HomeView()
}
