//
//  ProfilePictureView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI
import UIKit

@IBDesignable
class GroupPictureView: UIView {
    var hostingController = UIHostingController(rootView: CircularGroupPicture(groupPictureInfo: GroupPictureUserInput()))

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

    public func setBirthday(group: GroupViewModel) {
        hostingController.rootView = CircularGroupPicture(groupPictureInfo: GroupPictureUserInput(color1: group.colorGradient.color1.color, color2: group.colorGradient.color2.color))
    }
}
