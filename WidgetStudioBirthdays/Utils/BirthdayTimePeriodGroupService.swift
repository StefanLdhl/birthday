//
//  BirthdayTimePeriodGroupService.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.11.20.
//

import SwiftDate
import UIKit

class BirthdayTimePeriodGroupService {
    
    public static func getMostRelevantGroup(inputBirthdays: [BirthdayInfoViewModel]) -> BirthdaysInTimePeriodGroup? {
        
        return assignBirthdaysToTimePeriodGroup(inputBirthdays: inputBirthdays, justFirstGroup: true).first
        
    }
    
    public static func assignBirthdaysToTimePeriodGroup(inputBirthdays: [BirthdayInfoViewModel], justFirstGroup: Bool = false, shorter: Bool = false) -> [BirthdaysInTimePeriodGroup] {
        
        let birthdays = inputBirthdays.sorted(by: { $0.birthdateInYear < $1.birthdateInYear })
        
        var groups: [BirthdaysInTimePeriodGroup] = []
        var remainingBirthdays = birthdays

        for timePeriod in RemainingTimePeriod.allCases {
            var matchingBirthdays: [BirthdayInfoViewModel] = []

            for birthday in remainingBirthdays {
                if timePeriod.isMatchingDate(date: birthday.birthdateInYear) {
                    matchingBirthdays.append(birthday)
                    remainingBirthdays = remainingBirthdays.filter { $0.identifier != birthday.identifier }
                    continue
                }
            }

            if matchingBirthdays.count > 0 {
                
                groups.append(BirthdaysInTimePeriodGroup(name: timePeriod.localizedTitle(), birthdays: matchingBirthdays, isBirthdayToday: timePeriod == .today))
                
                if justFirstGroup {
                    return groups
                }
            }
        }

        if remainingBirthdays.count > 0 {
            let monthGroups = createMonthGroupsForDates(dates: remainingBirthdays, startingMonth: (Date() + 2.months).month, shortVersion: shorter)
            groups += monthGroups
        }

        return groups
    }

    private static func createMonthGroupsForDates(dates: [BirthdayInfoViewModel], startingMonth: Int, shortVersion: Bool = false) -> [BirthdaysInTimePeriodGroup] {
        var groups: [BirthdaysInTimePeriodGroup] = []

        let monthGroups = Dictionary(grouping: dates) { DateInRegion($0.birthdateInYear, region: Region.current).month }
        var monthInLoop = startingMonth
        let format = shortVersion ? "MMM" : "MMM yyyy"
        (1 ... 12).forEach { _ in

            if let matchingDates = monthGroups[monthInLoop], let firstDate = matchingDates[safe: 0] {
                let title = DateInRegion(firstDate.birthdateInYear, region: Region.current).toFormat(format)
                groups.append(BirthdaysInTimePeriodGroup(name: "\(title)", birthdays: matchingDates, isBirthdayToday: false))
            }

            monthInLoop += 1

            if monthInLoop > 12 {
                monthInLoop = 1
            }
        }

        return groups
    }
    
    

}
