//
//  Tooltip.swift
//  CookingApp
//
//  Created by Brian Anashari on 05/06/26.
//

import SwiftUI
import TipKit

struct ToolTip: Tip {
    var tipTitle: String
    var tipSubtitle: String
    var iconName: String
    var buttonTitle: String
    
    var title: Text {
            Text(tipTitle)
        }
            
        var message: Text? {
            Text(tipSubtitle)
        }
            
        var image: Image? {
            Image(systemName: iconName)
        }
            
        var actions: [Action] {
            if buttonTitle.isEmpty {
                return []
            } else {
                return [
                    Tip.Action(
                        id: "main-action",
                        title: buttonTitle
                    )
                ]
            }
        }
}

struct TestView: View {
    let toolTip = ToolTip(tipTitle: "Ambil Resep dari Web", tipSubtitle: "Tempel link resep pilihanmu di sini. Kami akan menyusun bahan dan langkah masaknya secara otomatis.", iconName: "link.badge.plus", buttonTitle: "Lihat Semua")
    
    var body: some View {
        Button {
            print("Test")
        } label: {
            Text("Test Tooltip")
        }
        .tint(Color.brandAccent)
        .padding()
        .popoverTip(toolTip, arrowEdge: .bottom)
        .tipViewStyle(ToolTipStyle())
    }
}


#Preview("Test View") {
    TestView()
}

extension View {
    @ViewBuilder
    func conditionalPopoverTip(_ condition: Bool, tip: ToolTip, arrowEdge: Edge, action: ((ToolTip.Action) -> Void)? = nil) -> some View {
        if condition {
            if let action = action {
                self.popoverTip(tip, arrowEdge: arrowEdge, action: action)
                    .tipViewStyle(ToolTipStyle())
            } else {
                self.popoverTip(tip, arrowEdge: arrowEdge)
                    .tipViewStyle(ToolTipStyle())
            }
        } else {
            self
        }
    }
}

