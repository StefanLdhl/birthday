//
//  InitialsCreator.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import Foundation

class NamesCreator {
    static func createInitials(for firstName: String?, lastName: String?) -> String? {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

        var initials = ""

        if let validFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines), validFirstName.count > 0 {
            let firstChar = validFirstName.prefix(1)

            if firstChar.rangeOfCharacter(from: characterset) != nil {
                initials = firstChar.uppercased()
            }
        }

        if let validLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines), validLastName.count > 0 {
            let firstChar = validLastName.prefix(1)

            if firstChar.rangeOfCharacter(from: characterset) != nil {
                initials += firstChar.uppercased()
            }
        }

        return initials.count > 0 ? initials : nil
    }

    static func createCombinedName(for firstName: String?, lastName: String?) -> String {
        var combinedName = ""
        let showLastNameFirst = GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst)

        let name1: String? = showLastNameFirst ? lastName : firstName
        let name2: String? = showLastNameFirst ? firstName : lastName

        if let validName1 = name1, validName1.count > 0 {
            combinedName = validName1
        }

        if let validName2 = name2, validName2.count > 0 {
            combinedName += combinedName.count > 0 ? " \(validName2)" : validName2
        }

        return combinedName
    }
}
