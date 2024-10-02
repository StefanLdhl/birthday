//
//  ProfilePictureView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI
import UIKit

@IBDesignable
class ProfilePictureView: UIView {
    var hostingController = UIHostingController(rootView: CircularProfilePicture(profilePictureInfo: ProfilePictureUserInput(profilePicture: nil, initials: nil)))

    private var colorGradient: ColorGradient?
    private var initials: String?
    private var photo: UIImage?
    private var shadow: Bool = false

    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(hostingController.view)
        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
    }

    public func preparePicture(initials: String?, photo: UIImage?, colorGradient: ColorGradient?, shadow: Bool) {
        self.initials = initials
        self.photo = photo
        self.colorGradient = colorGradient
        self.shadow = shadow
    }

    public func renderPicture() {
        DispatchQueue.main.async { [self] in
            let gradient = colorGradient ?? ColorGradientGenerator.getFallbackGradient()
            hostingController.view.frame = bounds
            hostingController.rootView = CircularProfilePicture(profilePictureInfo: ProfilePictureUserInput(profilePicture: photo, initials: initials, color1: gradient.color1.color, color2: gradient.color2.color, shadow: shadow))
        }
    }
}
