//
//  SubscriptionPeriodUnit+LocalizedName.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Foundation
import RevenueCat

extension SubscriptionPeriod.Unit {
    func getLocalizedName(plural: Bool) -> String? {
        switch self {
        case .day:
            return (plural ? "app.dateUnit.day.p" : "app.dateUnit.day").localize()
        case .week:
            return (plural ? "app.dateUnit.week.p" : "app.dateUnit.week").localize()
        case .month:
            return (plural ? "app.dateUnit.month.p" : "app.dateUnit.month").localize()
        case .year:
            return (plural ? "app.dateUnit.year.p" : "app.dateUnit.year").localize()
        default:
            return nil
        }
    }
}
