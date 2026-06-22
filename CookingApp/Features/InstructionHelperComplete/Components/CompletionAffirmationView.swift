//
//  CompletionAffirmationView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct CompletionAffirmationView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Yeay")
                .font(Font.largeTitle)
            
            Text("Masakanmu sudah siap!")
                .font(Font.title)
                .foregroundStyle(Color.labelLight)
        }
    }
}

#Preview {
    CompletionAffirmationView()
}
