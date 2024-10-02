//
//  ReminderType.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import SwiftDate
import UIKit

enum ReminderType: String, CaseIterable {
    case onBirthdate
    case daysBefore1
    case daysBefore2
    case daysBefore3
    case weeksBefore1
    case weeksBefore2
    case weeksBefore3
    case monthsBefore1
    case monthsBefore2
    case monthsBefore3

    public func localizedNotificationContent(triggerDate _: Date, birthday _: Date, name: String) -> (title: String, content: String) {
        guard name.count > 0 else {
            return (title: "app.notification.upcomingBirthdayText.fallBack.title".localize(), content: "app.notification.upcomingBirthdayText.fallBack.desc".localize())
        }

        let title = "app.notification.upcomingBirthdayText.title.\(self).%@".localize(values: name)

        if self == .onBirthdate {
            let desc = "app.notification.upcomingBirthdayText.content.onBirthday".localize()
            return (title: title, content: desc)
        }

        var prefix = ""
        if [ReminderType.daysBefore1, ReminderType.daysBefore2, ReminderType.daysBefore3].contains(self) {
            prefix = "app.notification.upcomingBirthdayText.content.soon.\(Int.random(in: 1 ... 3))".localize() + " "
        }

        let suffix = "app.notification.upcomingBirthdayText.content.suffix".localize()

        let content = prefix + suffix

        return (title: title, content: content)
    }

    public func localizedTitle() -> String {
        return "app.reminderType.\(rawValue)".localize()
    }

    public func getTimeBeforeDateDateComponents() -> DateComponents {
        switch self {
        case .onBirthdate:
            return 0.days

        case .daysBefore1:
            return 1.days

        case .daysBefore2:
            return 2.days

        case .weeksBefore1:
            return 1.weeks

        case .weeksBefore2:
            return 2.weeks

        case .daysBefore3:
            return 3.days

        case .weeksBefore3:
            return 3.weeks

        case .monthsBefore1:
            return 1.months

        case .monthsBefore2:
            return 2.months

        case .monthsBefore3:
            return 3.months
        }
    }
}
