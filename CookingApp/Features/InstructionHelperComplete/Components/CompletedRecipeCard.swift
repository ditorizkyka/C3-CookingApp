//
//  CompletedRecipeCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct CompletedRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(recipe.title)
                .font(Font.title)
            
            // Image
            Group {
                if let data = recipe.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let url = recipe.coverImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            ImagePlaceholder()
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ImagePlaceholder()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal)
            
            // Serving
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Image(systemName: "person.fill")
                    Text(recipe.portion == 0 ? "-" : "\(recipe.portion)")
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "clock.fill")
                    
                    Text("\(recipe.durationInMinutes) min")
                }
            }
            .font(Font.headline)
            .foregroundStyle(Color.brandAccent)
        }
    }
}
