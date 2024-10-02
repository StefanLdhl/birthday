//
//  RemainingTimePeriod.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.11.20.
//

import SwiftDate
import UIKit

enum RemainingTimePeriod: String, CaseIterable {
    case today
    case tomorrow
    case thisWeek
    case nextWeek
    case thisMonth
    case nextMonth

    public func isMatchingDate(date: Date) -> Bool {
        let dateInRegion = DateInRegion(date, region: .current)

        switch self {
        case .today: do {
                return dateInRegion.isToday
            }

        case .tomorrow: do {
                return dateInRegion.isTomorrow
            }

        case .thisWeek: do {
                return dateInRegion.compare(.isThisWeek)
            }

        case .nextWeek: do {
                return dateInRegion.compare(.isNextWeek)
            }

        case .thisMonth: do {
                return dateInRegion.compare(.isThisMonth)
            }

        case .nextMonth: do {
                return dateInRegion.compare(.isNextMonth)
            }
        }
    }

    public func localizedTitle() -> String {
        return "app.timePeriods.\(rawValue)".localize()
    }
}

extension RemainingTimePeriod {
    static func localizedTitle() -> String {
        return ""
    }
}
