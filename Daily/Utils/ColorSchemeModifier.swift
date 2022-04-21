//
//  ColorSchemeModifier.swift
//  Daily
//
//  Created by kasoly on 2022/4/1.
//

import Foundation
import SwiftUI

struct ColorSchemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("appColorScheme") var appColorScheme: Int = 0
    
    func body(content: Content) -> some View {
        if appColorScheme == 2 {
            return content.preferredColorScheme(.dark)
        } else if appColorScheme == 1 {
            return content.preferredColorScheme(.light)
        } else {
            return content.preferredColorScheme(colorScheme)
        }
    }
}
