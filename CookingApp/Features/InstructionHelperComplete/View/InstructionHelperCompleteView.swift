//
//  InstructionHelperCompleteView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct InstructionHelperCompleteView: View {
    var recipe: Recipe
    var onGoToHome: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.popToRoot) private var popToRoot
    
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
                NotificationCenter.default.post(name: Notification.Name("PopToRoot"), object: nil)
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
//    let container = PreviewContainer.shared
//    let ctx = container.mainContext
//    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
//    return InstructionHelperCompleteView(recipe: recipes.first!)
//        .modelContainer(container)
}
