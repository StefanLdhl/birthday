//
//  OtherDateRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 29.01.21.
//

import UIKit

class OtherDateRepository {
    public static func createNewOtherDate() -> OtherDate {
        let newOtherDate = OtherDate(context: CoreDataStack.defaultStack.managedObjectContext)

        newOtherDate.creationDate = Date()
        newOtherDate.fireDate = Date()
        newOtherDate.identifier = "newItem1"
        newOtherDate.lastChangeDate = Date()
        newOtherDate.name = "foo"
        newOtherDate.notification = false
        newOtherDate.type = "foo"

        return newOtherDate
    }
}
