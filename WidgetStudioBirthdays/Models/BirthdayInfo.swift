//
//  BirthdayInfo.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftDate
class BirthdayInfo {
    
    var identifier: String
    var name: String
    var date: Date
    var group: Group?
    var creationDate: Date
    var lastChangeDate: Date

    public init() {
        identifier = "birthday_\(UUID().uuidString)"
        name = ""
        date = Date() + 1.weeks
        creationDate = Date()
        lastChangeDate = Date()
    }


}
