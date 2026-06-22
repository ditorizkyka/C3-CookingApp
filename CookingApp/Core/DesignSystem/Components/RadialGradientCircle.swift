//
//  RadialGradiantCircle.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct RadialGradientCircle: View {
    var color: Color
    var offset: CGFloat
    var width: CGFloat
    var height: CGFloat
    
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
            .frame(width: width, height: height)
            .offset(y: offset)
    }
}

#Preview {
    RadialGradientCircle(color: Color.ovalGreen, offset: 0, width: 600, height: 600)
}
