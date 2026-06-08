//
//  EditAddHeaderRecipe.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditAddHeaderRecipe: View {
    var imageName: String?
    @Binding var titleRecipe: String
    
    var body: some View {
        VStack(spacing: 20) {
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
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .font(.title)
                .background(Color.surfaceElevated!)
                .cornerRadius(Radius.infinity)
        }
    }
}

#Preview {
    @Previewable @State var title = "Mie Kuah Spesial"
    EditAddHeaderRecipe(titleRecipe: $title)
}
