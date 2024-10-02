//
//  UserInput.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

class UserInput: ObservableObject {
    @Published var sortedBirthdays: [BirthdayInfoViewModel]
    @Published var header: String
    @Published var title: String
    @Published var subTitle: String
    @Published var birthdayIsToday: Bool = false

    @Published var additionalInfo1: String?
    @Published var additionalInfo2: String?

    init(sortedBirthdays: [BirthdayInfoViewModel], title: String, subTitle: String, header: String = "") {
        self.sortedBirthdays = sortedBirthdays
        self.title = title
        self.subTitle = subTitle
        self.header = header
    }

    init() {
        sortedBirthdays = []
        title = ""
        subTitle = ""
        header = ""
    }
}
