//
//  DateUnit.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import Foundation

enum DateUnit: Int, Codable {
    case minute
    case hour
    case day
    case week
    case month
    case year

    public var dateComponent: Calendar.Component {
        switch self {
        case .minute:
            return .minute

        case .hour:
            return .hour

        case .day:
            return .day

        case .week:
            return .weekOfMonth

        case .month:
            return .month

        case .year:
            return .year
        }
    }

    public var ticksUntilUpdate: Int {
        switch self {
        case .minute:
            return 60

        case .hour:
            return 24

        case .day:
            return 1
            
        case .week:
            return 1 // Irrelevant

        case .month:
            return 1 // Irrelevant

        case .year:
            return 1 // Irrelevant
        }
    }

    public func localizedName(plural: Bool) -> String {
        var translaltionKey = ""
        switch self {
        case .minute:
            translaltionKey = "app.dateUnit.minute"

        case .hour:
            translaltionKey = "app.dateUnit.hour"

        case .day:
            translaltionKey = "app.dateUnit.day"
            
        case .week:
            translaltionKey = "app.dateUnit.week"
            
        case .month:
            translaltionKey = "app.dateUnit.month"
            
        case .year:
            translaltionKey = "app.dateUnit.year"
        }

        translaltionKey.append(plural ? ".p" : "")

        return translaltionKey.localize()
    }
}

