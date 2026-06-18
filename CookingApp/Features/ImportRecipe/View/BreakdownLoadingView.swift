//
//  BreakdownLoadingView.swift
//  CookingApp
//

import SwiftUI
import Translation

struct BreakdownLoadingView: View {
    var onBreakdownComplete: ((Recipe) -> Void)? = nil
    var onError: ((String) -> Void)? = nil
    
    @StateObject private var viewModel: BreakdownLoadingViewModel
    
    init(recipe: Recipe, onBreakdownComplete: ((Recipe) -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        self.onBreakdownComplete = onBreakdownComplete
        self.onError = onError
        _viewModel = StateObject(wrappedValue: BreakdownLoadingViewModel(recipe: recipe))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if let errorMessage = viewModel.errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.brandSecondary)
                    
                    Text("Gagal Memproses Langkah")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelDark)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(Color.labelLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ButtonApp(title: "Coba Lagi", action: {
                        viewModel.resetAndRetry()
                    })
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        onBreakdownComplete?(viewModel.recipe)
                    }) {
                        Text("Lanjutkan Tanpa Rincian")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.brandPrimary)
                    }
                    .padding(.top, 8)
                }
            } else {
                // Loading state
                ProgressView()
                    .scaleEffect(2)
                    .tint(Color.brandPrimary)
                Text("Memproses Langkah Memasak...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelDark)
                
                Text("Menerjemahkan dan menyusun panduan")
                    .font(.subheadline)
                    .foregroundColor(Color.labelLight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceDefault.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startBreakdown()
        }
        .translationTask(viewModel.configIdToEn) { session in
            await viewModel.translateToEnglish(session: session)
        }
        .translationTask(viewModel.configEnToId) { session in
            await viewModel.translateToIndonesian(session: session, onComplete: onBreakdownComplete)
        }
    }
}
