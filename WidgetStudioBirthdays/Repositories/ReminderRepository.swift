//
//  ReminderRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import CoreData
import Foundation
import SwiftDate

class ReminderRepository {
    static func getAllReminders(predicate: NSPredicate? = nil) -> [Reminder] {
        let request = Reminder.fetchRequest() as NSFetchRequest<Reminder>

        if let predicateToSet = predicate {
            request.predicate = predicateToSet
        }

        do {
            let result = try CoreDataStack.defaultStack.managedObjectContext.fetch(request) as [Reminder]
            let shoudlCheckForDuplicates = GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated)
            return (shoudlCheckForDuplicates ? removePossibleDuplicates(reminders: result) : result)

        } catch {
            print("Failed")
        }

        return []
    }

    public static func updateFromGroup(groupViewModel: GroupViewModel, groupModel: Group) {
        let reminders = getAllReminders(predicate: NSPredicate(format: "group.identifier == %@ && NOT (identifier IN %@)", groupViewModel.identifier, groupViewModel.reminders.map { $0.identifier }))

        for reminder in reminders {
            CoreDataStack.defaultStack.managedObjectContext.delete(reminder)
        }

        let modifiedReminders = groupViewModel.reminders.filter { $0.modified }

        for reminder in modifiedReminders {
            _ = updateFromViewModel(reminderViewModel: reminder, group: groupModel)
        }
    }

    private static func removePossibleDuplicates(reminders: [Reminder]) -> [Reminder] {
        var checkedReminders: [Reminder] = []
        var somethingChanged = false

        for reminder in reminders.sorted(by: { $0.creationDate ?? Date() < $1.creationDate ?? Date() }) {
            if checkedReminders.map({ $0.identifier }).contains(reminder.identifier ?? "") {
                CoreDataStack.defaultStack.managedObjectContext.delete(reminder)
                somethingChanged = true
            } else {
                checkedReminders.append(reminder)
            }
        }
        if somethingChanged {
            CoreDataStack.defaultStack.saveContext()
        }

        return checkedReminders
    }

    public static func updateFromViewModel(reminderViewModel: ReminderViewModel, group: Group) -> Reminder? {
        var existingBirthday = getAllReminders(predicate: NSPredicate(format: "identifier == %@", reminderViewModel.identifier)).first

        if existingBirthday == nil, reminderViewModel.identifier == "new" {
            existingBirthday = Reminder(context: CoreDataStack.defaultStack.managedObjectContext)
            existingBirthday?.identifier = createUniqueReminderId()
            existingBirthday?.creationDate = Date()
            existingBirthday?.group = group
        }

        guard let validBirthday = existingBirthday else {
            return nil
        }

        validBirthday.customText = reminderViewModel.customText
        validBirthday.type = reminderViewModel.type.rawValue
        validBirthday.time = reminderViewModel.time
        validBirthday.sound = reminderViewModel.sound.rawValue
        validBirthday.lastChangeDate = Date()

        return existingBirthday
    }

    public static func addDefaultReminder(group: Group, identifier: String?, type: ReminderType) -> Reminder {
        let newReminder = Reminder(context: CoreDataStack.defaultStack.managedObjectContext)
        newReminder.identifier = identifier ?? createUniqueReminderId()
        newReminder.group = group
        newReminder.creationDate = Date()
        newReminder.lastChangeDate = Date()
        newReminder.customText = ""
        newReminder.type = type.rawValue
        newReminder.time = DateInRegion(year: 2020, month: 10, day: 10, hour: 9, minute: 00, second: 0, region: Region.current).date
        newReminder.sound = ReminderSound.defaultSound.rawValue
        newReminder.deactivated = false
        newReminder.groupedNotification = false

        CoreDataStack.defaultStack.saveContext()

        return newReminder
    }

    private static func createUniqueReminderId() -> String {
        return "reminder\(UUID().uuidString)"
    }
    
    /// Gibt alle Daten als Dictionary zurück.
    static func getAllDataAsDictionary() -> [[String: String]] {
        let allReminders = getAllReminders()
        var reminderDictArray: [[String: String]] = []

        for group in allReminders {
            reminderDictArray.append(group.asDictionary())
        }

        return reminderDictArray
    }
    
    
}
