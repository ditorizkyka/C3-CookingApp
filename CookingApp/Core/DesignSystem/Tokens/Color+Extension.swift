//
//  Color.swift
//  CookingApp
//
//  Created by Brian Anashari on 05/06/26.
//

import SwiftUI

extension Color {
    
    
    // Brand
    static let brandAccent = Color("#004820")
    static let brandPrimary = Color("#004820")
    static let brandSecondary = Color("#FFCC21")
    
    // Label
    static let labelDark = Color("#121B15")
    static let labelLight = Color("#727B76")
    static let labelLightest = Color("#FFFFFF")
    
    // Surface
    static let surfaceDefault = Color("#F2F2F7")
    static let surfaceElevated = Color("#FAFFFC")
    static let surfaceBrand = Color("#004820")
    
    // Recipe Card
    static let recipeCardGreen = Color("#60A624")
    static let recipeCardBronze = Color("#A66C24")
    static let recipeCardPurple = Color("#6B24A6")
    static let recipeCardCyan = Color("#24A690")
    static let recipeCardRed = Color("#FF383C")
}

extension Color {
    init?(_ hex: String) {
        // Remove whitespaces and any "#" character
        let sanitizedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        
        // Scan the string into a 64-bit integer
        guard Scanner(string: sanitizedHex).scanHexInt64(&rgbValue) else { return nil }
        
        let r, g, b, a: Double
        
        switch sanitizedHex.count {
        case 6: // Standard RGB format (e.g., "FF5733")
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA format with Alpha (e.g., "FF5733FF")
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        default: // Invalid length
            return nil
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
