//
//  RecipeLibrarySortMenu.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct RecipeLibrarySortMenu: View {
    @ObservedObject var viewModel: RecipeLibraryViewModel
    
    var body: some View {
        Menu {
            Button {
                viewModel.sortOption = .name
            } label: {
                HStack {
                    Text("Name")
                    if viewModel.sortOption == .name {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                viewModel.sortOption = .dateAdded
            } label: {
                HStack {
                    Text("Date Added")
                    if viewModel.sortOption == .dateAdded {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
//            Image(systemName: "line.3.horizontal.decrease.circle")
//                .foregroundStyle(.primary)
        }
    }
}
