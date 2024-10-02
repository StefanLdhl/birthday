//
//  Color+Hex.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import Foundation
import SwiftUI

extension Color {
    init(hexString: String, opacity: Double = 1.0) {
        guard let hex = UInt(String(hexString.suffix(6)), radix: 16) else {
            self.init(UIColor.white)
            return
        }
        
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
