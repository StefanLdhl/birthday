//
//  QuickActionSettingsTableViewCell.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import UIKit

class QuickActionSettingsTableViewCell: UITableViewCell {
    @IBOutlet var actionTitleLabel: UILabel!
    @IBOutlet var actionIconImage: UIImageView!
    @IBOutlet var infoButton: UIButton!

    var infoButtonPressed: (() -> Void) = {}

    @IBAction func buttonAction(_: UIButton) {
        infoButtonPressed()
    }
}
