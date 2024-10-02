//
//  CircularGradientView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 03.12.20.
//

import Foundation
import UIKit

@IBDesignable

class CircularGradientView: UIView {
    private var gradient = CAGradientLayer()
    private var imageOverlay = UIImageView()

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFit
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public func updateGradient(gradient: ColorGradient, systemImageName: String? = nil) {
        DispatchQueue.main.async {
            
            self.gradient.colors = [gradient.color1.uiColor.cgColor,gradient.color2.uiColor.cgColor]
            self.imageOverlay.image = UIImage()
            
            if let imageName = systemImageName {
                self.imageOverlay.image = UIImage(systemName: imageName)

            }
        }
    }

    private func setup() {
        imageOverlay.frame = self.bounds.insetBy(dx: 7, dy: 7)
        imageOverlay.backgroundColor = .clear
        imageOverlay.contentMode = .scaleAspectFit
        imageOverlay.tintColor = .white
        
        self.insertSubview(imageOverlay, at: 0)
        
        layer.cornerRadius = frame.size.width / 2
        layer.borderWidth = 0
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
        

        backgroundColor = .clear
        gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.insertSublayer(gradient, at: 0)
        
        

    }
}

