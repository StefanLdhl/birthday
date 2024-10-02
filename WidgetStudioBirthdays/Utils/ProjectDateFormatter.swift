//
//  DateTimeFormat.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 13.01.21.
//

import Foundation
import SwiftDate
import UIKit
import WidgetKit

class ProjectDateFormatter {
    public static func formatDate(date: Date, showYearIfAvailable: Bool? = nil) -> String {
        let formatter = DateFormatter()
        let showYear = showYearIfAvailable ?? (date.year > 1)

        formatter.locale = Locale.preferredLocale()

        if let customFormattingId = GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_customDateFormattingId), let customFormatting = CustomDateFormatType(rawValue: customFormattingId)?.getFormat() {
            formatter.dateFormat = showYear ? customFormatting.withYear : customFormatting.withoutYear
        } else if showYear {
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: 0, locale: Locale.preferredLocale())

        } else {
            formatter.setLocalizedDateFormatFromTemplate("ddMMM")
        }

        return formatter.string(from: date)
    }

    public static func formatDateForBirthday(birthday: BirthdayInfoViewModel, showAgeIfAvailable: Bool = true, showWeekdayIfAvailable: Bool = false, dateStyle _: DateFormatter.Style = .medium) -> String {
        var formattedDate = formatDate(date: birthday.birthdate, showYearIfAvailable: false)

        if showWeekdayIfAvailable, !birthday.birthdayIsToday, RemainingTimePeriod.tomorrow.isMatchingDate(date: birthday.birthdateInYear) || RemainingTimePeriod.thisWeek.isMatchingDate(date: birthday.birthdateInYear) {
            formattedDate = "\(getWeekDayOfDate(date: birthday.birthdateInYear)) | \(formattedDate)"
        }

        if showAgeIfAvailable, let age = birthday.currentAge, age >= 0 {
            if birthday.birthdayIsToday {
                formattedDate += " | \("app.views.list.cells.yearsOldSuffix.today.%d".localize(values: age))"

            } else {
                formattedDate += " | \("app.views.list.cells.yearsOldSuffix.%d".localize(values: age + 1))"
            }

            if (birthday.birthdayIsToday && birthday.birthdayType != .normal) || (!birthday.birthdayIsToday && birthday.nextAgeBirthdayType != .normal) {
                formattedDate += " ★"
            }
        }

        return formattedDate
    }

    private static func getWeekDayOfDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.preferredLocale()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let weekDay = dateFormatter.string(from: date)
        return weekDay
    }

    public static func formatDateForBirthdayPreview(birthdate: Date, showAgeIfAvailable: Bool = true, dateStyle _: DateFormatter.Style = .medium) -> String {
        var formattedDate = formatDate(date: birthdate)

        let birthdateInYear = birthdate.dateWithTodaysYear
        let birthdayIsToday = DateInRegion(birthdateInYear, region: .current).isToday

        if showAgeIfAvailable, let age = birthdate.year > 10 ? Date.yearsSinceDate(birthdate: birthdate) : nil {
            if birthdayIsToday {
                formattedDate += " | \("app.views.list.cells.yearsOldSuffix.today.%d".localize(values: age))"

            } else {
                formattedDate += " | \("app.views.list.cells.yearsOldSuffix.%d".localize(values: age + 1))"
            }
        }

        return formattedDate
    }
}

enum CustomDateFormatType: String, CaseIterable {
    case custom1
    case custom2
    case custom3
    case custom4
    case custom5
    case custom6
    case custom7
    case custom8

    public func getFormat() -> CustomDateFormat {
        switch self {
        case .custom1:
            return CustomDateFormat(withYear: "dd.MM.yyyy", withoutYear: "dd.MM")
        case .custom2:
            return CustomDateFormat(withYear: "dd-MM-yyyy", withoutYear: "dd-MM")

        case .custom3:
            return CustomDateFormat(withYear: "yyyy-M-d", withoutYear: "M-d")

        case .custom4:
            return CustomDateFormat(withYear: "dd/MM/yyyy", withoutYear: "dd/MM")

        case .custom5:
            return CustomDateFormat(withYear: "yyyy/M/d", withoutYear: "M/d")

        case .custom6:
            return CustomDateFormat(withYear: "yyyy/MM/dd", withoutYear: "MM/dd")

        case .custom7:
            return CustomDateFormat(withYear: "M/d/yyyy", withoutYear: "M/d")

        case .custom8:
            return CustomDateFormat(withYear: "dd MMM yyyy", withoutYear: "dd MMM")
        }
    }
}

public struct CustomDateFormat {
    var withYear: String
    var withoutYear: String
}
