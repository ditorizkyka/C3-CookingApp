//
//  ButtonCard.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 05/06/26.
//

import SwiftUI

struct ButtonCard: View {
    var body: some View {
        Button(action: {
            print("Tombol ditekan")
        }) {
            HStack(spacing: 10) {
                if let iconName = icon, !iconName.isEmpty {
                    Image(systemName: iconName)
                    Text(textButton)
                } else {
                    
                    Text(textButton)
                }
            }
            .font(.headline)
            .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
        .cornerRadius(Radius.button)
        .padding(.horizontal)
    }
}

#Preview {
    ButtonCard()
}
