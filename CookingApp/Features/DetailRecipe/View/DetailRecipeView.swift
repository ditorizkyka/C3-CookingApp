//
//  DetailRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

import SwiftUI

struct DetailRecipeView: View {
    var imageName: String?
    var containerHeight: CGFloat = 221
    var cornerRadius: CGFloat = 12
       
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
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
                                    .foregroundColor(.gray)
                                    
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                }
                            }
                            
                    .frame(width: .infinity, height: containerHeight)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    
                    
                    //    // MARK: - Extract Recipe Data
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                                
                }
            }
            
        }
        
    }
}

#Preview {
    DetailRecipeView()
}
