//
//  MultiBirthdayWidgetIntentHandler.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 25.01.21.
//

import Foundation
import Intents

class MultiBirthdayWidgetIntentHandler: NSObject, MultiBirthdayWidgetIntentHandling {
    func provideGroupsOptionsCollection(for intent: MultiBirthdayWidgetIntent, with completion: @escaping (INObjectCollection<BirthdayGroup>?, Error?) -> Void) {
        let groups = GroupRepository.getAllGroups()
        var groupVM = groups.map { GroupViewModel(group: $0) }
        groupVM = groupVM.sorted(by: { $0.linkedBirthdaysCount == $1.linkedBirthdaysCount ? $0.name.lowercased() < $1.name.lowercased() : $0.linkedBirthdaysCount > $1.linkedBirthdaysCount })

        let mappedGroups = groupVM.map { IntentTypesMapper.mapGroup(group: $0) }

        completion(INObjectCollection(items: mappedGroups), nil)
    }
}
