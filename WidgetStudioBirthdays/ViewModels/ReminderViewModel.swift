//
//  ReminderViewModel.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import Foundation

class ReminderViewModel {
    var identifier: String
    var customText: String

    var sound: ReminderSound
    var type: ReminderType
    var creationDate: Date
    var time: Date

    var modified: Bool = false

    init(reminder: Reminder) {
        identifier = reminder.identifier ?? ""
        customText = reminder.customText ?? ""
        sound = ReminderSound(rawValue: reminder.sound ?? "") ?? .defaultSound
        type = ReminderType(rawValue: reminder.type ?? "") ?? .onBirthdate
        time = reminder.time ?? Date()
        creationDate = reminder.creationDate ?? Date()
        modified = false
    }

    init(identifier: String) {
        self.identifier = identifier
        customText = ""
        sound = ReminderSound.defaultSound
        type = ReminderType.onBirthdate
        time = Date()
        creationDate = Date()
        modified = false

    }
}
