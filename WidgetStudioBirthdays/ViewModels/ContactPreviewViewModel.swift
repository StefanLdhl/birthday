//
//  ContactPreviewViewModel.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import UIKit

struct ContactPreviewViewModel {
    var birthday: Date
    var anniversary: Date?
    var firstName: String
    var lastName: String
    var picture: UIImage?
    var cnContactId: String
    var colorGradient: ColorGradient?
}
