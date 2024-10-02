//
//  MultiUserInput.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 25.01.21.
//

import Foundation
import SwiftUI
import WidgetKit

class MultiUserInput: ObservableObject {
    @Published var birthdayCountdowns: [MultiUserInputCountdown]
    @Published var title: String
    @Published var subtitle: String

    init(birthdayCountdowns: [MultiUserInputCountdown], title: String, subtitle: String) {
        self.birthdayCountdowns = birthdayCountdowns
        self.title = title
        self.subtitle = subtitle
    }

    init() {
        birthdayCountdowns = []
        title = ""
        subtitle = ""
    }
}
