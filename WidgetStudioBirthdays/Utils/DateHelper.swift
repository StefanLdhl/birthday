//
//  DateHelper.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation

class DateHelper {
    
    public static func removeTimeComponent(date: Date) -> Date? {
        let cal = Calendar(identifier: .iso8601)
        return cal.startOfDay(for: date)
    }
    
    
    public static func combineDateWithTime(date: Date, time: Date, ignoreSeconds: Bool = false) -> Date {
        let calendar = Calendar(identifier: .iso8601)

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents((ignoreSeconds ? [.hour, .minute] : [.hour, .minute, .second]), from: time)

        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second

        guard let result = calendar.date(from: components) else {
            return removeTimeComponent(date: date) ?? date
        }
        
        return result
    }
    
    
}
