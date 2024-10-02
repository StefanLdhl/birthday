//
//  IntentTypesMapper.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 25.01.21.
//

import Foundation
import Intents

class IntentTypesMapper {
    public static func mapGroup(group: GroupViewModel) -> BirthdayGroup {
        let userDateEntry = BirthdayGroup(identifier: group.identifier, display: group.name)
        
        userDateEntry.displayImage = INImage(named: "defaultIcon2")
        userDateEntry.subtitleString = "widget.intent.groupList.subtitle.%d".localize(values: group.linkedBirthdaysCount)

        return userDateEntry
    }
}
