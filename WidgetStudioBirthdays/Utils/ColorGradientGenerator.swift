//
//  ColorGradientGenerator.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 19.12.20.
//

import Foundation
import UIKit
import SwiftUI

class ColorGradientGenerator {
    static func getDefaultGradients() -> [ColorGradient] {
        return [
            ColorGradient(color1: ProjectColor(value: "defaultColor6"),
                        color2: ProjectColor(value: "defaultColor8"), gradientId: 1),

            ColorGradient(color1: ProjectColor(value: "defaultColor8"),
                        color2: ProjectColor(value: "defaultColor9"), gradientId: 2),

            ColorGradient(color1: ProjectColor(value: "defaultColor1"),
                        color2: ProjectColor(value: "defaultColor3"), gradientId: 3),

            ColorGradient(color1: ProjectColor(value: "defaultColor5"),
                        color2: ProjectColor(value: "defaultColor8"), gradientId: 7),

            ColorGradient(color1: ProjectColor(value: "defaultColor4"),
                        color2: ProjectColor(value: "defaultColor5"), gradientId: 5),

            ColorGradient(color1: ProjectColor(value: "defaultColor5"),
                        color2: ProjectColor(value: "defaultColor6"), gradientId: 6),

            ColorGradient(color1: ProjectColor(value: "defaultColor4"),
                        color2: ProjectColor(value: "defaultColor6"), gradientId: 4),

            ColorGradient(color1: ProjectColor(value: "defaultColor4"),
                        color2: ProjectColor(value: "defaultColor3"), gradientId: 8),

            ColorGradient(color1: ProjectColor(value: "defaultColor6"),
                        color2: ProjectColor(value: "defaultColor7"), gradientId: 9),

            ColorGradient(color1: ProjectColor(value: "defaultColor2"),
                        color2: ProjectColor(value: "defaultColor3"), gradientId: 10),

            ColorGradient(color1: ProjectColor(value: "defaultColor7"),
                        color2: ProjectColor(value: "defaultColor8"), gradientId: 11),

            ColorGradient(color1: ProjectColor(value: "defaultColor9"),
                        color2: ProjectColor(value: "defaultColor1"), gradientId:12),

            ColorGradient(color1: ProjectColor(value: "#FF2D55"),
                        color2: ProjectColor(value: "#020D85"), gradientId: 13),

            ColorGradient(color1: ProjectColor(value: "#29323c"),
                        color2: ProjectColor(value: "#485563"), gradientId: 14),

            ColorGradient(color1: ProjectColor(value: "#424242"),
                        color2: ProjectColor(value: "#303030"), gradientId: 15),
        ]
    }

    
    static func getPremiumGradientIds() -> [Int] {
        if CurrentUser.isUserPro() {
            return []
        }

        return [9,10,11,12,13,14,15]
    }
    
    
    static func getNextGroupGradient() -> ColorGradient {
        let usedColorIds = GroupRepository.getAllGroups().map { Int($0.colorId) }
        let allGradients = getDefaultGradients()

        let notUsedIds = allGradients.map { $0.gradientId }.filter { !usedColorIds.contains($0) }

        if let matchingGradient = allGradients.first(where: { notUsedIds.contains($0.gradientId) }) {
            return matchingGradient
        }

        return getRandomGradient()
    }

    static func getRandomGradient() -> ColorGradient {
        return getDefaultGradients().randomElement() ?? getFallbackGradient()
    }

    public static func getFallbackGradient() -> ColorGradient {
        return  ColorGradient(color1: ProjectColor(value: "defaultColor6"),
                              color2: ProjectColor(value: "defaultColor8"), gradientId: 1)
    }
    
    
    public static func getGroupGradientFallback() -> ColorGradient {
        return  ColorGradient(color1: ProjectColor(value: "defaultColor6"),
                              color2: ProjectColor(value: "defaultColor8"), gradientId: 1)
    }
}

struct ColorGradient {
    var color1: ProjectColor
    var color2: ProjectColor
    var gradientId: Int
}


struct ProjectColor: Codable {
    var value: String

    var color: Color {
        return Color(uiColor)
    }

    var uiColor: UIColor {
        if value.starts(with: "#") {
            return UIColor(hexString: value)
        } else {
            return UIColor(named: value) ?? .white
        }
    }
}
