//
//  EntityExtension.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 29.01.21.
//

import Foundation
import SwiftDate

extension Birthday {
    func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]

        dictionary["birthdate"] = birthdate?.toISO() ?? ""
        dictionary["cnId"] = cnContactId ?? ""
        dictionary["cnDate"] = cnContactImportDate?.toISO() ?? ""
        dictionary["creationDate"] = creationDate?.toISO() ?? ""
        dictionary["lastChangeDate"] = lastChangeDate?.toISO() ?? ""
        dictionary["picture"] = "as file in folder"
        dictionary["firstName"] = firstName ?? ""
        dictionary["lastName"] = lastName ?? ""
        dictionary["group"] = "\(group?.name ?? "")"
        dictionary["identifier"] = identifier ?? ""
        dictionary["memorialized"] = "\(memorialized)"

        return dictionary
    }
}

extension Group {
    func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]

        dictionary["colors"] = "\(color1 ?? ""), \(color2 ?? "")"
        dictionary["creationDate"] = creationDate?.toISO() ?? ""
        dictionary["lastChangeDate"] = lastChangeDate?.toISO() ?? ""
        dictionary["identifier"] = identifier ?? ""
        dictionary["name"] = name ?? ""
        dictionary["birthdays"] = "\(birthdays?.count ?? 0)"
        dictionary["template"] = "\(preferredMessageTemplate?.title ?? "")"
        dictionary["connectedReminders"] = "\(dailyReminders?.count ?? 0)"

        return dictionary
    }
}

extension Message {
    func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]

        dictionary["content"] = content ?? ""
        dictionary["title"] = title ?? ""
        dictionary["creationDate"] = creationDate?.toISO() ?? ""
        dictionary["lastChangeDate"] = lastChangeDate?.toISO() ?? ""
        dictionary["identifier"] = identifier ?? ""
        dictionary["isDefault"] = "\(isDefault)"
        dictionary["group"] = group?.name ?? ""

        return dictionary
    }
}

extension Reminder {
    func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]

        dictionary["creationDate"] = creationDate?.toISO() ?? ""
        dictionary["lastChangeDate"] = lastChangeDate?.toISO() ?? ""
        dictionary["identifier"] = identifier ?? ""
        dictionary["sound"] = sound ?? ""
        dictionary["time"] = time?.toISO() ?? ""
        dictionary["type"] = type ?? ""
        dictionary["deactivated"] = "\(deactivated)"

        return dictionary
    }
}
