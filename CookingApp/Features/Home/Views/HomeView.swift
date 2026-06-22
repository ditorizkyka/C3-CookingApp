//
//  HomeView.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI
import SwiftData
import TipKit


struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Query private var savedRecipes: [Recipe]
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var clipboardManager = ClipboardManager()
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    @State private var buttonFrame: CGRect = .zero
    
    var allRecipes: [Recipe] {
        return Array(savedRecipes.reversed())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceBrandElevated.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    SearchStateObserver(isSearchActive: $viewModel.isSearchActive)
                    
                    if viewModel.isSearchActive {
                        RecipeGridSearchResultView(
                            searchQuery: viewModel.searchRecipe,
                            filteredRecipes: viewModel.filteredRecipes(from: allRecipes),
                            onTapRecipe: { recipe in
                                if let originalIndex = allRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                    viewModel.importedRecipe = nil
                                    viewModel.selectedIndex = originalIndex
                                    viewModel.navigateToDetail = true
                                }
                            }
                        )
                    } else {
                        HomeActionButtons(
                            viewModel: viewModel,
                            onboardingStep: $onboardingStep,
                            buttonFrame: $buttonFrame
                        )
                        
                        HomeRecipeListSection(
                            viewModel: viewModel,
                            allRecipes: allRecipes
                        )
                        .sheet(isPresented: $viewModel.isShowingImportSheet) {
                            ImportRecipeSheet(onImport: { url in
                                viewModel.handleImport(url: url)
                            })
                            .presentationDetents([.fraction(0.5), .large])
                            .presentationDragIndicator(.visible)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                        .frame(maxHeight: .infinity)
                    }
                }
                .searchable(
                    text: $viewModel.searchRecipe,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Cari resep..."
                )
                .searchDictationBehavior(.inline(activation: .onSelect))
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $viewModel.navigateToManual) {
                    AddManualRecipeView(onManualComplete: { recipe in
                        viewModel.handleManualRecipeComplete(recipe: recipe)
                    })
                }
                .navigationDestination(isPresented: $viewModel.navigateToDetail) {
                    if let recipe = viewModel.importedRecipe {
                        DetailRecipeView(recipe: recipe, isFromImport: true, onDismiss: {
                            viewModel.dismissDetail()
                        })
                    } else if let index = viewModel.selectedIndex, index < allRecipes.count {
                        DetailRecipeView(recipe: allRecipes[index], onDismiss: { viewModel.dismissDetail() })
                    }
                }
                .navigationDestination(isPresented: $viewModel.navigateToLoading) {
                    ImportLoadingView(urlToScrape: viewModel.urlToScrape, onComplete: { recipe in
                        viewModel.handleScrapingComplete(recipe: recipe)
                    })
                }
                .navigationDestination(isPresented: $viewModel.navigateToLibrary) {
                    RecipeLibraryView()
                }
                
                VStack {
                    Spacer()
                    if clipboardManager.showClipboardToast, let detectedURL = clipboardManager.detectedURL {
                        ClipboardToastView(
                            url: detectedURL,
                            onImport: {
                                viewModel.importedLink = detectedURL
                                clipboardManager.dismissToast()
                                viewModel.showWebPreviewFromClipboard = true
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
            viewModel.resetNavigation()
        }
        .holeMaskOverlay(isActive: Binding(get: { onboardingStep == 0 }, set: { if !$0 && onboardingStep == 0 { onboardingStep = 1 } }), holeFrame: buttonFrame, cornerRadius: Radius.large)
        .sheet(isPresented: $viewModel.showWebPreviewFromClipboard) {
            WebsitePreviewSheet(
                urlString: viewModel.importedLink,
                onImport: {
                    viewModel.handleClipboardImport(url: viewModel.importedLink)
                },
                onDismiss: {
                    viewModel.showWebPreviewFromClipboard = false
                }
            )
        }
        .onAppear {
            clipboardManager.startMonitoring()
        }
        .onDisappear {
            clipboardManager.stopMonitoring()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                clipboardManager.checkNow()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PopToRoot"))) { _ in
            viewModel.resetNavigation()
        }
        .onChange(of: viewModel.navigateToDetail) { _, newValue in
            if !newValue {
                viewModel.importedRecipe = nil
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewContainer.shared)
}
