//
//  UIColor+Hex.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 03.12.20.
//

import SwiftUI
import UIKit

public extension UIColor {
    convenience init(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.removeFirst(1)
        }

        if cString.count != 6 {
            self.init(Color.red)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: 1.0)
    }
}

extension UIColor {
    var hexString: String {
        cgColor.components![0 ..< 3]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
}
