//
//  EditAddHeaderRecipe.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditAddHeaderRecipe: View {
    var imageName: String?
    @State private var titleRecipe: String = "Food"
    
    var body: some View {
        VStack(spacing:20) {
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
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: 10, y: -10)
                        }
                        
                }
        
                else {
                    Button(action: {
                        print("Panggil Photo Picker di sini")
                        // Aksi untuk membuka galeri
                    }) {
                        VStack(spacing: 12) {
                            // Tumpukan Ikon Foto & Plus
                            ZStack(alignment: .bottomTrailing) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .background(Color.white) // Agar tidak transparan
                                    .clipShape(Circle())
                                    .offset(x: 4, y: 4)
                            }
                            
                            Text("Tambah Foto")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 221)
                        .background(Color.labelLightest!) // Warna background agak terang
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Garis putus-putus (Dashed Border)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.small)
                                .stroke(Color.labelLight!, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                        )
                    }
                    .buttonStyle(.plain) // Agar warna tombol tidak berubah jadi biru bawaan Apple
                }
            }
            TextField("", text: $titleRecipe)
                .padding(.horizontal,15)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Color.labelLightest
                )
                .cornerRadius(Radius.infinity)
        }
//        .padding(.horizontal,16)
    }
}

// MARK: - Komponen Reusable Gambar (Tetap sama)
//struct RecipeHeaderImage: View {
//    var imageName: String?
//    var height: CGFloat = 221
//    var cornerRadius: CGFloat = 12
//    
//    var body: some View {
//        Group {
//            if let name = imageName, !name.isEmpty {
//                Image(name)
//                    .resizable()
//                    .scaledToFill()
//            } else {
//                VStack(spacing: 8) {
//                    Image(systemName: "photo")
//                        .font(.largeTitle)
//                    Text("No Image")
//                        .font(.caption)
//                }
//                .foregroundColor(.gray)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.gray.opacity(0.2))
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: height)
//        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//    }
//}

#Preview {
    EditAddHeaderRecipe()
}
