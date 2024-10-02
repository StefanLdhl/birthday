//
//  UIImage+Resize.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import UIKit

extension UIImage {
    func resize(to width: Int, height: Int) -> UIImage {
        let newSize = CGSize(width: width, height: height)

        let renderer = UIGraphicsImageRenderer(size: newSize)

        let image = renderer.image { _ in
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        }
        return image
    }

    func resizeToSquare(sideLength: Int) -> UIImage {
        let safeSideLength = min(Int(min(size.height, size.width)), sideLength)
        return resize(to: safeSideLength, height: safeSideLength)
    }
}
