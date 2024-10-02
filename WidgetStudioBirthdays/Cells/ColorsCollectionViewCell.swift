//
//  ColorsCollectionViewCell.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 13.01.21.
//

import UIKit

class ColorsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var circularGadientView: CircularGradientView!
    @IBOutlet var editOverlayImage: UIImageView!
    @IBOutlet var lockedOverlayImage: UIImageView!

}

class SpecialColorsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var circularGadientView: CircularGradientView!
}
