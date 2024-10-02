//
//  UIView+Gradient.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 12.01.21.
//

import UIKit

extension UIView {
    func applyGradient(colors: [CGColor]) {
        
        let gradient = CAGradientLayer()
        gradient.colors = colors

        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
}
