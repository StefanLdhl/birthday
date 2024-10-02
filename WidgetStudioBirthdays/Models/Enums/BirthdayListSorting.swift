//
//  BirthdayListSorting.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.11.20.
//

import UIKit

enum BirthdayListSorting: Int {
    case byDate
    case alphabetically
    case byGroup

    public func getIcon() -> UIImage? {
        switch self {
        case .alphabetically:
            return UIImage(systemName: "list.bullet.indent")

        case .byDate:
            return UIImage(systemName: "list.bullet")

        case .byGroup:
            return UIImage(systemName: "list.bullet.below.rectangle")
        }
    }

    public func getAccessibilityValueName() -> String {
        switch self {
        case .alphabetically:
            return "app.accessibility.views.list.sortButton.value1".localize()

        case .byDate:
            return "app.accessibility.views.list.sortButton.value2".localize()

        case .byGroup:
            return "app.accessibility.views.list.sortButton.value3".localize()
        }
    }
}
