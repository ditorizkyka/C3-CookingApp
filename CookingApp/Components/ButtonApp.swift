//
//  ButtonApp.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 05/06/26.
//


//
//  ButtonApp.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 05/06/26.
//

import SwiftUI


struct ButtonApp: View {
    
    
    var body: some View {
           
        Button(action: {
            print("Tombol ditekan")
        }) {
            HStack(spacing:20) {
                
                
                Image(systemName: "plus")
                Text("Button Native")
//                    .font()
                    .foregroundColor(.white) // Warna
            }
        }
        .foregroundColor(.white) // Warna teks kontras
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary) // Warna biru native Apple
        .cornerRadius(Radius.button)
        .padding()
        

    }
}

#Preview {
    ButtonApp()
}
