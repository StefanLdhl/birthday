//
//  Date+Zodiac.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 15.01.21.
//

import Foundation

public extension Date {
    var zodiacSignString: String {
        let zodiacSign = ZodiacManager.zodiacFrom(date: self)

        return zodiacSign.localizedName()

        // let chineseZodiacSign = ZodiacManager.chineseZodiacFrom(date: self)
        // return chineseZodiacSign.localizedName()
    }
}
