//
//  RadialGradiantCircle.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct RadialGradiantCircle: View {
    var color: Color
    var offset: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        color,
                        color.opacity(0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
            )
            .frame(width: 600, height: 600)
            .offset(y: offset)
    }
}
