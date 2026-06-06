//
//  CustomTipStyle.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI
import TipKit

struct ToolTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Icon
            if let image = configuration.image {
                image
                    .font(Font.title)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    if let title = configuration.title {
                        title
                            .font(Font.headline)
                    }
                    
                    // Subtitle
                    if let message = configuration.message {
                        message
                            .font(Font.subheadline)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Divider
                    Divider()
                    
                    // Action
                    ForEach(configuration.actions) { action in
                        Button(action: action.handler) {
                            action.label()
                                .font(Font.subheadline)
                                .foregroundStyle(Color.brandAccent!)
                        }
                    }
                }
            }
        }
        .padding(20)
    }
}
