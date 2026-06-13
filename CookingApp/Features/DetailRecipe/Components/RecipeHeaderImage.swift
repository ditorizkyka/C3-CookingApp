//
//  RecipeHeaderImage.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 09/06/26.
//
import SwiftUI
import PhotosUI

// MARK: - View Mode Header (displays cover image from URL or local data)
struct RecipeDetailHeader: View {
    var imageName: String?
    var imageUrl: URL?
    var imageData: Data?
    var titleRecipe: String = "Recipe"
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    // Show locally saved image (user picked from photo library)
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let url = imageUrl {
                    // Show image from scraped URL
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
                                .frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if let name = imageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    ImagePlaceholder()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 221)
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            
            Text(titleRecipe)
                .padding(.horizontal, 0)
                .padding(.vertical, 36)
                .frame(height: 48)
                .font(.title)
                .cornerRadius(Radius.infinity)
        }
    }
}

// MARK: - Placeholder for missing images
struct ImagePlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.largeTitle)
            Text("No Image")
                .font(.caption)
        }
        .foregroundColor(Color.labelLightest!)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.tertiarySystemFill))
    }
}

// MARK: - Recipe Header (switches between view and edit mode)
struct RecipeHeader: View {
    @ObservedObject var viewModel: DetailRecipeViewModel
    var isEdited: Bool = false
    var imageName: String?
    
    var body: some View {
        if isEdited {
            RecipeEditHeader(viewModel: viewModel, imageName: imageName)
        } else {
            RecipeDetailHeader(
                imageName: imageName,
                imageUrl: viewModel.recipe.coverImageUrl,
                imageData: viewModel.recipe.coverImageData,
                titleRecipe: viewModel.recipe.title
            )
        }
    }
}

// MARK: - Edit Mode Header (with photo picker to change cover)
struct RecipeEditHeader: View {
    @ObservedObject var viewModel: DetailRecipeViewModel
    var imageName: String?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    /// Whether we currently have an image to display
    private var hasImage: Bool {
        viewModel.recipe.coverImageData != nil || viewModel.recipe.coverImageUrl != nil || (imageName != nil && !imageName!.isEmpty)
    }
    
    var body: some View {
        VStack {
            Group {
                if hasImage {
                    // Show current image with delete button
                    ZStack(alignment: .topTrailing) {
                        currentImageView
                            .frame(maxWidth: .infinity)
                            .frame(height: 221)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                        
                        Button(action: {
                            // Remove the cover image
                            viewModel.recipe.coverImageData = nil
                            viewModel.recipe.coverImageUrl = nil
                        }) {
                            Image(systemName: AppIcon.minusFill)
                                .font(.title2)
                                .foregroundColor(Color.actionDelete!)
                                .background(Color.surfaceElevated!)
                                .clipShape(Circle())
                        }
                        .offset(x: 10, y: -10)
                    }
                    .onTapGesture {
                        showPhotoPicker = true
                    }
                } else {
                    // No image — show picker button
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        VStack(spacing: 12) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.labelLight!)
                                
                                Image(systemName: AppIcon.plusFill)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.labelLight!)
                                    .background(Color.surfaceElevated!)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: 4)
                            }
                            
                            Text("Tambah Foto")
                                .font(.callout)
                                .foregroundColor(Color.labelLight!)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 221)
                        .background(Color.surfaceElevated!)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.small)
                                .stroke(Color.labelLight!, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            TextField("Nama Resep", text: $viewModel.recipe.title)
                .padding(.horizontal, 20)
                .padding(.vertical, 36)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .font(.title)
                .background(Color.surfaceElevated)
                .cornerRadius(Radius.infinity)
                .padding(.vertical, 20)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.recipe.coverImageData = data
                    // Clear URL since we now have local data
                    viewModel.recipe.coverImageUrl = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private var currentImageView: some View {
        if let data = viewModel.recipe.coverImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let url = viewModel.recipe.coverImageUrl {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    ImagePlaceholder()
                case .empty:
                    ProgressView().frame(height: 221)
                @unknown default:
                    EmptyView()
                }
            }
        } else if let name = imageName, !name.isEmpty {
            Image(name)
                .resizable()
                .scaledToFill()
        } else {
            ImagePlaceholder()
        }
    }
}

#Preview {
    @Previewable @State var title = "Mie Kuah Spesial"
    ScrollView {
        // Preview is simplified
    }
}
