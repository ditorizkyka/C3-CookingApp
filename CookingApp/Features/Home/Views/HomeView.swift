//
//  HomeView.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI
import TipKit


struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var searchRecipe: String = ""
    @State private var isSearchActive: Bool = false
    @State private var selectedIndex: Int? = nil
    @State private var allRecipes: [Recipe] = Recipe.dummyRecipes
    
    var filteredRecipes: [Recipe] {
        if searchRecipe.isEmpty {
            return allRecipes
        } else {
            return allRecipes.filter { $0.title.localizedCaseInsensitiveContains(searchRecipe) }
        }
    }
    
    
    @State private var navigateToManual = false
    @State private var navigateToDetail = false
    @State private var navigateToLoading = false
    
    @State private var isShowingImportSheet = false
    
    // Import flow state
    @State private var urlToScrape: String = ""
    @State private var importedRecipe: Recipe?
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    
    
    //    MARK : CLIPBOARD VARIABLE
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var importedLink: String = ""
    
    // Controls whether the WebsitePreviewSheet is shown for a clipboard-detected URL
    @State private var showWebPreviewFromClipboard = false
    
    
    @State private var buttonFrame: CGRect = .zero
    let importRecipeTip = ToolTip(tipTitle: "Ambil Resep dari Web", tipSubtitle: "Tempel link resep pilihanmu di sini. Kami akan menyusun bahan dan langkah masaknya secara otomatis.", iconName: "link.badge.plus", buttonTitle: "")
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 24) {
                SearchStateObserver(isSearchActive: $isSearchActive)
                
                if isSearchActive {
                    // Tampilan saat search aktif (mirip RecipeLibrary)
                    RecipeGridSearchResultView(
                        searchQuery: searchRecipe,
                        filteredRecipes: filteredRecipes,
                        onTapRecipe: { recipe in
                            if let originalIndex = allRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                selectedIndex = originalIndex
                                navigateToDetail = true
                            }
                        }
                    )
                } else {
                    // Tampilan default HomeView
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
                        ImportRecipeSheet(onImport: { url in
                            urlToScrape = url
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
                    if let recipe = importedRecipe {
                        DetailRecipeView(recipe: recipe, isFromImport: true)
                    } else {
                        DetailRecipeView()
                    }
                }
                .navigationDestination(isPresented: $navigateToLoading) {
                    LoadingRecipeView(urlToScrape: urlToScrape, onScrapingComplete: { recipe in
                        importedRecipe = recipe
                    })
                }
                
                // MARK: - Clipboard Toast pinned to bottom
                VStack {
                    Spacer()
                    if clipboardManager.showClipboardToast, let detectedURL = clipboardManager.detectedURL {
                        ClipboardToastView(
                            url: detectedURL,
                            onImport: {
                                self.importedLink = detectedURL
                                clipboardManager.dismissToast()
                                showWebPreviewFromClipboard = true
                            },
                            onDismiss: {
                                clipboardManager.dismissToast()
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                    }
                }
                .zIndex(1)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: clipboardManager.showClipboardToast)
            }
            
            
        }
        .environment(\.popToRoot) {
            navigateToDetail = false
            navigateToLoading = false
        }
        .holeMaskOverlay(isActive: Binding(get: { onboardingStep == 0 }, set: { if !$0 && onboardingStep == 0 { onboardingStep = 1 } }), holeFrame: buttonFrame, cornerRadius: Radius.small)
        // MARK: - Clipboard → Website Preview Sheet
        .sheet(isPresented: $showWebPreviewFromClipboard) {
            WebsitePreviewSheet(
                urlString: importedLink,
                onImport: {
                    showWebPreviewFromClipboard = false
                    urlToScrape = importedLink
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToLoading = true
                    }
                },
                onDismiss: {
                    showWebPreviewFromClipboard = false
                }
            )
        }
        .onAppear {
            clipboardManager.startMonitoring()
        }
        .onDisappear {
            clipboardManager.stopMonitoring()
        }
        // Re-check clipboard immediately when app comes back to foreground
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                clipboardManager.checkNow()
            }
        }
    }
    

}

#Preview {
    HomeView()
}
