//
//  Font.swift
//  CookingApp
//
//  Created by Farhah Nashrillah on 05/06/26.
//

import SwiftUI

extension Font {
    static let xXXLargeTitle = Font.custom("", size: 68, relativeTo: .largeTitle).weight(.bold)
    static let xXLargeTitle = Font.custom("", size: 58, relativeTo: .largeTitle).weight(.bold)
    static let xLargeTitle = Font.custom("", size: 48, relativeTo: .largeTitle).weight(.bold)
    static let largeTitle = Font.system(.largeTitle).weight(.bold)
    static let title = Font.system(.title2).weight(.bold)
    static let headline = Font.system(.headline).weight(.semibold)
    static let body = Font.system(.body).weight(.regular)
    static let subHeadline = Font.system(.subheadline).weight(.regular)
    static let footnote = Font.system(.footnote).weight(.regular)
}
