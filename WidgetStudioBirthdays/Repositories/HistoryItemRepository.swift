//
//  HistoryItemRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 29.01.21.
//

import UIKit

class HistoryItemRepository {
    public static func createNewHistoryItem() -> HistoryItem {
        let newHistoryItem = HistoryItem(context: CoreDataStack.defaultStack.managedObjectContext)

        newHistoryItem.identifier = "newItem1"
        newHistoryItem.note = "..."
        newHistoryItem.creationDate = Date()
        newHistoryItem.celebrationType = "foo"
        newHistoryItem.celebrationDate = Date()

        return newHistoryItem
    }
}
