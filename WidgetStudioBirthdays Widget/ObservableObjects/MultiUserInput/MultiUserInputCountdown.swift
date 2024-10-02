//
//  MultiUserInputGroup.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 25.01.21.
//

import SwiftUI
import UIKit
import WidgetKit

class MultiUserInputCountdown: ObservableObject {
    
    @Published var birthday: BirthdayInfoViewModel
    @Published var daysLeft: Int
    @Published var color1: Color
    @Published var color2: Color

    init(birthday: BirthdayInfoViewModel) {
        self.birthday = birthday
        self.daysLeft = birthday.daysLeftToBirthday
        self.color1 = birthday.group.colorGradient.color1.color
        self.color2 = birthday.group.colorGradient.color2.color
    }
}
