//
//  ContactGroupViewModel.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 02.12.20.
//

import Foundation

class GroupViewModel {
    var identifier: String
    var name: String
    var linkedBirthdaysCount: Int = 0
    var creationDate: Date

    var colorGradient: ColorGradient
    var reminders: [ReminderViewModel]
    var preferredMessageTemplate: MessagesViewModel?

    init(group: Group) {
        identifier = group.identifier ?? ""
        name = group.name ?? ""
        creationDate = group.creationDate ?? Date()
        linkedBirthdaysCount = group.birthdays?.count ?? 0
        colorGradient = ColorGradient(color1: ProjectColor(value: group.color1 ?? "defaultColor1"),
                                      color2: ProjectColor(value: group.color2 ?? "defaultColor1"),
                                      gradientId: Int(group.colorId))

        if let originalReminders = group.dailyReminders?.allObjects as? [Reminder] {
            reminders = originalReminders.map { ReminderViewModel(reminder: $0) }
        } else {
            reminders = []
        }

        if let preferredTemplate = group.preferredMessageTemplate {
            preferredMessageTemplate = MessagesViewModel(message: preferredTemplate)
        }
    }

    init(identifier: String) {
        self.identifier = identifier
        name = ""
        colorGradient = ColorGradientGenerator.getGroupGradientFallback()
        reminders = []
        creationDate = Date()
    }

    static func getFallbackGroupViewModel() -> GroupViewModel {
        return GroupViewModel(identifier: "missingGroup")
    }
}

extension GroupViewModel: Identifiable, Hashable, Equatable {
    var id: String { identifier }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GroupViewModel, rhs: GroupViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
