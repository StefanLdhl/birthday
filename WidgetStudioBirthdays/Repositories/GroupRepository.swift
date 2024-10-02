//
//  GroupRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 02.12.20.
//

import CoreData
import Foundation
import UIKit

class GroupRepository {
    public static func getAllGroups(predicate: NSPredicate? = nil) -> [Group] {
        let request = Group.fetchRequest() as NSFetchRequest<Group>

        if let predicateToSet = predicate {
            request.predicate = predicateToSet
        }

        do {
            let result = try CoreDataStack.defaultStack.managedObjectContext.fetch(request) as [Group]
            let shoudlCheckForDuplicates = GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated)
            return (shoudlCheckForDuplicates ? removePossibleDuplicates(groups: result) : result)

        } catch {
            print("Failed")
        }

        return []
    }

    public static func getGroupbyId(identifier: String) -> Group? {
        guard identifier != "missingGroup" else {
            return nil
        }

        return getAllGroups(predicate: NSPredicate(format: "identifier == %@", identifier)).first
    }

    private static func removePossibleDuplicates(groups: [Group]) -> [Group] {
        var checkedGroups: [Group] = []
        var somethingChanged = false

        for group in groups.sorted(by: { $0.creationDate ?? Date() < $1.creationDate ?? Date() }) {
            if let match = checkedGroups.filter({ $0.identifier == group.identifier }).first {
                for birthday in (group.birthdays?.allObjects as? [Birthday]) ?? [] {
                    birthday.group = match
                }
                CoreDataStack.defaultStack.managedObjectContext.delete(group)
                somethingChanged = true
            } else {
                checkedGroups.append(group)
            }
        }
        if somethingChanged {
            CoreDataStack.defaultStack.saveContext()
        }

        return checkedGroups
    }

    static func deleteGroup(identifier: String, moveItemsToGroupWithID newGroupId: String? = nil) {
        guard let groupToDelete = getGroupbyId(identifier: identifier) else {
            return
        }

        if let newGroupIdentifier = newGroupId, let linkedBirthdays = groupToDelete.birthdays?.allObjects as? [Birthday], linkedBirthdays.count > 0, let newGroup = getGroupbyId(identifier: newGroupIdentifier) {
            let birthdaysInNewGroup = newGroup.birthdays?.allObjects as? [Birthday] ?? []
            let birthdaysInNewGroupIds = birthdaysInNewGroup.map { $0.identifier
            }

            // Geburtstage der alten Gruppe mit neuer Gruppe verknüpfen.
            for birthdayFromOldGroup in linkedBirthdays {
                guard !birthdaysInNewGroupIds.contains(birthdayFromOldGroup.identifier) else {
                    continue
                }
                birthdayFromOldGroup.group = newGroup
            }
        }

        CoreDataStack.defaultStack.managedObjectContext.delete(groupToDelete)
        CoreDataStack.defaultStack.saveContext()
    }

    static func addNewGroup(name: String, identifier: String? = nil, createDefaultReminder: Bool = true) -> Group {
        let gradient = ColorGradientGenerator.getNextGroupGradient()
        let newGroup = Group(context: CoreDataStack.defaultStack.managedObjectContext)

        newGroup.name = name
        newGroup.color1 = gradient.color1.uiColor.hexString
        newGroup.color2 = gradient.color2.uiColor.hexString
        newGroup.colorId = Int16(gradient.gradientId)
        newGroup.creationDate = Date()
        newGroup.lastChangeDate = Date()

        newGroup.identifier = identifier ?? createUniqueGroupId()
        CoreDataStack.defaultStack.saveContext()

        if createDefaultReminder {
            _ = ReminderRepository.addDefaultReminder(group: newGroup, identifier: "defaultReminder_\(newGroup.identifier ?? "\(Int.random(in: 1 ... 99999))")", type: .onBirthdate)
        }
        return newGroup
    }

    public static func updateFromViewModel(groupViewModel: GroupViewModel) -> Group? {
        guard let existingGroup = getGroupbyId(identifier: groupViewModel.identifier) else {
            return nil
        }

        existingGroup.name = groupViewModel.name

        let colorGradient = groupViewModel.colorGradient
        existingGroup.color1 = colorGradient.color1.uiColor.hexString
        existingGroup.color2 = colorGradient.color2.uiColor.hexString
        existingGroup.colorId = Int16(colorGradient.gradientId)
        existingGroup.lastChangeDate = Date()

        if let identifier = groupViewModel.preferredMessageTemplate?.identifier, let message = MessageRepository.getMessagebyId(identifier: identifier) {
            existingGroup.preferredMessageTemplate = message
        } else {
            existingGroup.preferredMessageTemplate = nil
        }

        ReminderRepository.updateFromGroup(groupViewModel: groupViewModel, groupModel: existingGroup)
        CoreDataStack.defaultStack.saveContext()

        return existingGroup
    }

    private static func createUniqueGroupId() -> String {
        return "group_\(UUID().uuidString)"
    }

    /// Gibt alle Daten als Dictionary zurück.
    static func getAllDataAsDictionary() -> [[String: String]] {
        let allGroups = getAllGroups()
        var groupDictArray: [[String: String]] = []

        for group in allGroups {
            groupDictArray.append(group.asDictionary())
        }

        return groupDictArray
    }
}
