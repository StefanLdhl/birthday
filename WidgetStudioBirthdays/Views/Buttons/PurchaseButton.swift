//
//  PurchaseButton.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 05.02.21.
//

import Foundation
import UIKit

public class PurchaseButton: UIButton {
    let containerView = UIView()

    // MARK: Overrides

    private var gradientIsSet = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func refreshShadowColor() {
        layer.shadowColor = backgroundColor?.cgColor ?? UIColor.black.cgColor
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if !gradientIsSet {
            let buttonGradientLayer = CAGradientLayer()
            buttonGradientLayer.colors = [UIColor(hexString: "#FF3B30").cgColor, UIColor(hexString: "#FF9500").cgColor]
            buttonGradientLayer.startPoint = CGPoint.zero
            buttonGradientLayer.endPoint = CGPoint(x: 1, y: 0)

            buttonGradientLayer.frame = bounds
            layer.insertSublayer(buttonGradientLayer, at: 0)

            
            gradientIsSet = true
        }
    }

    public func setPrice(title: String, subtitle: String?, isPromo: Bool = false, originalPrice: String? = nil) {
        layoutIfNeeded()
        let titleFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        let titleAttributes = [NSMutableAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]

        if let subtitleString = subtitle {
            let subtitleFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
            let subtitleAttributes = [NSMutableAttributedString.Key.font: subtitleFont, .foregroundColor: UIColor(named: "defaultColor3") ?? .yellow]

            let oldPriceAttributes: [NSAttributedString.Key: Any] = [NSMutableAttributedString.Key.font: subtitleFont, .foregroundColor: UIColor(named: "defaultColor3") ?? .yellow, NSAttributedString.Key.strikethroughStyle: 2, NSAttributedString.Key.strikethroughColor: UIColor.red.withAlphaComponent(0.4)]

            let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
            let subtitleString = NSMutableAttributedString(string: subtitleString, attributes: subtitleAttributes)

            titleString.append(subtitleString)

            // Originalpreis durchgestrichen anzeigen wenn verfügbar
            if let validOriginalPrice = originalPrice {
                let oldPriceString = NSMutableAttributedString(string: validOriginalPrice, attributes: oldPriceAttributes)
                titleString.append(NSAttributedString(string: " | ", attributes: subtitleAttributes))
                titleString.append(oldPriceString)
            }

            setAttributedTitle(titleString, for: .normal)

        } else {
            let title = NSMutableAttributedString(string: title, attributes: titleAttributes)
            setAttributedTitle(title, for: .normal)
        }

        if isPromo {
            layer.borderWidth = 2
            layer.borderColor = UIColor.orange.cgColor

        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func setup() {
        backgroundColor = UIColor.systemBlue
        layer.cornerRadius = bounds.size.height / 2
        clipsToBounds = true

        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
    }
}

