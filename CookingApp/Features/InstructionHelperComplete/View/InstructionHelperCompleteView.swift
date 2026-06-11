//
//  InstructionHelperCompleteView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct InstructionHelperCompleteView: View {
    var recipe: Recipe
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 64) {
            // Affirmation
            VStack(spacing: 8) {
                Text("Yeay")
                    .font(Font.largeTitle)
                
                Text("Masakanmu sudah siap!")
                    .font(Font.title)
                    .foregroundStyle(Color.labelLight!)
            }
            
            // Recipe
            VStack(spacing: 16) {
                // Title
                Text(recipe.title)
                    .font(Font.title)
                
                // Image
                Image("img_test")
                
                // Serving
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        
                        Text("\(recipe.portion)")
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock.fill")
                        
                        Text("\(recipe.durationInMinutes) min")
                    }
                }
                .font(Font.headline)
                .foregroundStyle(Color.brandAccent!)
            }
            
            // Button
            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        dismiss()
                    }
                }
            } label: {
                Text("Selesai")
                    .font(Font.headline)
            }
            .buttonStyle(.plain)
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(Color.brandAccent)
            .foregroundStyle(Color.labelLightest!)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .background(
            VStack {
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -125, width: 600, height: 600)
                
                Spacer()
                
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: 125, width: 600, height: 600)
            }
            .ignoresSafeArea()
        )
    }
}

#Preview {
    InstructionHelperCompleteView(recipe: Recipe.dummyRecipes.first!)
}
