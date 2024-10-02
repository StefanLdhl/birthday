//
//  WidgetContentStyler.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import Foundation
import SwiftDate
import UIKit


class WidgetContentStyler {
    public static func createBirthdayNamesString(birthdays: [BirthdayInfoViewModel]) -> (title: String, subtitle: String) {
        var titleString = ""
        let subTitleString = ""

        guard let firstName = birthdays.first?.firstName else {
            return ("-", "")
        }

        // Plus anhängen
        titleString = "\(firstName)\(birthdays.count > 1 ? " +\(birthdays.count - 1)" : "")"

        //Sonderfall wenn genau zwei und passend
        if birthdays.count == 2, let secondName = birthdays[safe: 2] {
            let combinedNames = "\(firstName) & \(secondName)"

            if combinedNames.count <= 13 {
                titleString = combinedNames
            }
        }

        return (titleString, subTitleString)
    }
}
