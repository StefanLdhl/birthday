//
//  BirthdayTableViewCell.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI
import UIKit

class BirthdayTableViewCell: UITableViewCell {
    private weak var hostingController: UIHostingController<CircularProfilePicture>?

    @IBOutlet var profilePictureFrame: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var milestoneImageView: UIImageView!
    @IBOutlet var subtitleLabel: UILabel!

    public func setupPicture(parent: UIViewController, initials: String?, photo: UIImage?, colorGradient: ColorGradient?, shadow _: Bool) {
        let gradient = colorGradient ?? ColorGradientGenerator.getFallbackGradient()
        let fixedPictureSize = CGSize(width: 45, height: 45)

        let root = CircularProfilePicture(profilePictureInfo: ProfilePictureUserInput(profilePicture: photo, initials: initials, color1: gradient.color1.color, color2: gradient.color2.color, shadow: false, fixedSize: fixedPictureSize))

        if let controller = hostingController {
            controller.rootView = root
            controller.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: root)
            hostingController = host
            host.view.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = false
            layoutIfNeeded()
            parent.addChild(host)
            profilePictureFrame.addSubview(host.view)
            host.view.layoutIfNeeded()
        }
    }
}

class BirthdayListSearchTableViewCell: BirthdayTableViewCell {}
