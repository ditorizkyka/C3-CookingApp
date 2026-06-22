//
//  InstructionHelperCompleteView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI
import AVFoundation

struct InstructionHelperCompleteView: View {
    @StateObject private var viewModel: InstructionHelperCompleteViewModel
    @StateObject private var speechManager = SpeechManager()
    @State private var audioPlayer: AVAudioPlayer?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.popToRoot) private var popToRoot
    
    init(recipe: Recipe, onGoToHome: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: InstructionHelperCompleteViewModel(recipe: recipe, onGoToHome: onGoToHome))
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 64) {
            // Affirmation Component
            CompletionAffirmationView()
            
            // Recipe Component
            CompletedRecipeCard(recipe: viewModel.recipe)
            
            // Button
            Button {
                viewModel.finishCooking()
            } label: {
                Text("Selesai")
                    .font(Font.headline)
            }
            .buttonStyle(.plain)
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(Color.brandAccent)
            .foregroundStyle(Color.labelLightest)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        }
        .navigationBarBackButtonHidden(true)
        .background(
            VStack {
                RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: -125, width: 600, height: 600)
                
                Spacer()
                
                RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: 125, width: 600, height: 600)
            }
            .ignoresSafeArea()
        )
        .overlay {
            ConfettiView()
                .ignoresSafeArea()
        }
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            if let soundAsset = NSDataAsset(name: "confetti_sound") {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    audioPlayer = try AVAudioPlayer(data: soundAsset.data)
                    audioPlayer?.play()
                } catch {
                    print("Gagal memainkan suara confetti: \(error)")
                }
            }
        }
        .onDisappear {
            speechManager.stopSpeaking()
        }
    }
}

#Preview {
//    let container = PreviewContainer.shared
//    let ctx = container.mainContext
//    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
//    return InstructionHelperCompleteView(recipe: recipes.first!)
//        .modelContainer(container)
}
