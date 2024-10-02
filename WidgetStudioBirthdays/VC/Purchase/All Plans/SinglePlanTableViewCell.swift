//
//  SinglePlanTableViewCell.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import UIKit

class SinglePlanTableViewCell: UITableViewCell {
    @IBOutlet var mainView: UIView!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var strikedPriceLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!

    var isProminent: Bool = false

    private var borderGradientLayer: CAGradientLayer?
    private var backgroundGradientLayer: CAGradientLayer?
    private let cornerRadius = 12.0

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setupGradients()
    }

    func setupGradients() {
        mainView.layer.cornerRadius = cornerRadius
        mainView.clipsToBounds = true

        // Background
        backgroundGradientLayer?.removeFromSuperlayer()
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor(hexString: "#FF3B30").cgColor, UIColor(hexString: "#FF9500").cgColor]
        backgroundGradientLayer.startPoint = CGPoint.zero
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        backgroundGradientLayer.cornerRadius = cornerRadius

        backgroundGradientLayer.frame = mainView.bounds

        mainView.layer.insertSublayer(backgroundGradientLayer, at: 0)
        self.backgroundGradientLayer = backgroundGradientLayer

        // Border
        borderGradientLayer?.removeFromSuperlayer()

        let defaultColors: [UIColor] = [UIColor.white, UIColor.white]
        let goldColors: [UIColor] = [UIColor(hexString: "#F9F295"), UIColor(hexString: "#E0AA3E"), UIColor(hexString: "#E0AA3E"), UIColor(hexString: "#B88A44")]

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        gradientLayer.colors = (isProminent ? goldColors : defaultColors).map { $0.cgColor }

        let shape = CAShapeLayer()
        shape.lineWidth = isProminent ? 6 : 4
        shape.path = UIBezierPath(roundedRect: mainView.bounds, cornerRadius: cornerRadius).cgPath

        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = shape
        mainView.layer.addSublayer(gradientLayer)
        borderGradientLayer = gradientLayer
    }
}
