//
//  RecipeHeaderImage.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 09/06/26.
//
import SwiftUI

// MARK: - Komponen Reusable Gambar
struct RecipeDetailHeader: View {
    var imageName: String?
    var titleRecipe : String = "Recipe"
    
    var body: some View {
        VStack(alignment: .leading,) {
            Group {
                if let name = imageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("No Image")
                            .font(.caption)
                    }
                    .foregroundColor(Color.labelLightest!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.labelLight!)
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

struct RecipeHeader : View {
    var isEdited : Bool = false
    @State var titleRecipe : String = "Recipe"
    var imageName: String?
    
    var body : some View {
        if isEdited {
            RecipeEditHeader(imageName: imageName, titleRecipe: $titleRecipe)
        } else {
            RecipeDetailHeader(imageName: imageName,
            titleRecipe: titleRecipe)
        }
    }
}

//
//  EditAddHeaderRecipe.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

struct RecipeEditHeader: View {
    var imageName: String?
    @Binding var titleRecipe: String
    
    var body: some View {
        VStack() {
            Group {
                if let name = imageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 221)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                        .overlay(alignment: .topTrailing) {
                            Button(action: {
                                print("Tombol hapus ditekan")
                            }) {
                                Image(systemName: AppIcon.minusFill)
                                    .font(.title2)
                                    .foregroundColor(Color.actionDelete!)
                                    .background(Color.surfaceElevated!)
                                    .clipShape(Circle())
                            }
                            .offset(x: 10, y: -10)
                        }
                        
                }
        
                else {
                    Button(action: {
                        print("Panggil Photo Picker di sini")
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
            TextField("Nama Resep", text: $titleRecipe)
                .padding(.horizontal, 20)
                .padding(.vertical, 36)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .font(.title)
                .background(Color.surfaceElevated)
                .cornerRadius(Radius.infinity)
                .padding(.vertical,20)
        }
    }
}

#Preview {
    @Previewable @State var title = "Mie Kuah Spesial"
    ScrollView {
        RecipeHeader(isEdited: true, titleRecipe: "Resep", imageName: "")
        
        RecipeHeader(isEdited: false, titleRecipe: "Resep", imageName: "")
    }
    

}

