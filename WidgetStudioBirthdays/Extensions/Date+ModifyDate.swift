//
//  Date+ModifyDate.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftDate

extension Date {
    var dateWithoutTime: Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }

    var dateWithTodaysYear: Date {
        let calendar = Calendar.current
        var dateComponents: DateComponents? = calendar.dateComponents([.year, .month, .day], from: self)

        dateComponents?.year = calendar.component(.year, from: Date())

        guard var returndata = calendar.date(from: dateComponents!) else {
            return self
        }

        if returndata < Date(), !calendar.isDateInToday(returndata) {
            returndata = returndata.dateBySet([.year: returndata.year + 1]) ?? returndata
        }

        return returndata
    }

    var dateWithoutYear: Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        dateComponents.year = 1
        return calendar.date(from: dateComponents) ?? date
    }

    static func yearsSinceDate(birthdate: Date) -> Int {
        let ageComponents = Calendar.current.dateComponents([.year],
                                                            from: birthdate.startOfDay,
                                                            to: Date().startOfDay)
        return ageComponents.year ?? 0
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    static func deleteSeconds(date: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return calendar.date(from: dateComponents) ?? date

        // return date.dateTruncated([.second]) ?? date
    }
}
