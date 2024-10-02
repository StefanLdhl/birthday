//
//  InitialsCreator.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import Foundation

class NamesCreator {
    static func create(for firstName: String?, lastName: String?) -> String? {
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
}
