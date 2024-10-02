//
//  DefaultDataProvider.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 22.01.21.
//

import Foundation

class DefaultDataProvider {
    public static func generateDefaultData() {
        // Gruppen, Reminder, TextTemplates anlegen

        // Gruppen
        let groupFriends = GroupRepository.addNewGroup(name: "app.defaultData.groups.friends".localize(), identifier: "defaultGroupFriends", createDefaultReminder: false)
        let groupWork = GroupRepository.addNewGroup(name: "app.defaultData.groups.work".localize(), identifier: "defaultGroupWork", createDefaultReminder: false)

        // Reminder
        _ = ReminderRepository.addDefaultReminder(group: groupFriends, identifier: "defaultFriendsReminder1", type: .onBirthdate)

        _ = ReminderRepository.addDefaultReminder(group: groupFriends, identifier: "defaultFriendsReminder2", type: .daysBefore1)

        _ = ReminderRepository.addDefaultReminder(group: groupWork, identifier: "defaultWorkReminder1", type: .onBirthdate)

        // Vorlagen
        _ = MessageRepository.addNewLocalizableMessage(title: "app.defaultData.messageTemplates.default\(1).title", content: "app.defaultData.messageTemplates.default\(1).content", isDefault: true, identifier: "defaultTemplate\(1)", group: groupFriends)

        _ = MessageRepository.addNewLocalizableMessage(title: "app.defaultData.messageTemplates.default\(2).title", content: "app.defaultData.messageTemplates.default\(2).content", isDefault: true, identifier: "defaultTemplate\(2)", group: nil)

        _ = MessageRepository.addNewLocalizableMessage(title: "app.defaultData.messageTemplates.default\(3).title", content: "app.defaultData.messageTemplates.default\(3).content", isDefault: true, identifier: "defaultTemplate\(3)", group: groupWork)
    }
}
