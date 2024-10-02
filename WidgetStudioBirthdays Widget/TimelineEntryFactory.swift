//
//  TimelineEntryFactory.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import SwiftDate
import UIKit

class TimelineEntryFactory {
    static func createTimelineEntries(for birthdays: [Birthday]) -> [DateTimelineEntry] {
        var timelineEntries: [DateTimelineEntry] = []
        let startOfTheDay = Date().startOfDay
        let endOfTheDay = Date().endOfDay

        // Gruppe laden. Profibilder ignorieren und zunächst nicht aus Db laden.
        let birthdayViewModels = birthdays.map { BirthdayInfoViewModelMapper.map(birthday: $0, includeImage: false) }
        let groupedBirthdays = BirthdayTimePeriodGroupService.assignBirthdaysToTimePeriodGroup(inputBirthdays: birthdayViewModels, justFirstGroup: true)

        guard let relevantGroup = groupedBirthdays.first else {
            return [DateTimelineEntry(date: Date(), userInput: userInputFromData(nearestBirthdays: [], otherBirthdays: [], nextBirthday: Date(), header: "-"))]
        }

        let groupIsBirthdayGroup = relevantGroup.isBirthdayToday

        // Nach Datum sortieren
        let birthdaysInGroup = relevantGroup.birthdays.sorted(by: { $0.birthdateInYear < $1.birthdateInYear })

        // Nähesten Geburtstag laden
        guard let nextBirthday = birthdaysInGroup.first?.birthdateInYear else {
            return []
        }

        // Geburstage zunächst aufteilen, um näheste Gebsurtage separat behandeln zu können.
        var nearestBirthdays = birthdaysInGroup.filter { $0.birthdateInYear == nextBirthday }
        var otherBirthdays = birthdaysInGroup.filter { $0.birthdateInYear != nextBirthday }

        // Profilbilder nachladen
        for i in 0 ..< nearestBirthdays.count {
            nearestBirthdays[i].fetchProfilePic()
        }

        for i in 0 ..< otherBirthdays.count {
            otherBirthdays[i].fetchProfilePic()
        }

        if nearestBirthdays.count > 1 {
            let refreshingTimeInMinutes = 10
            let refreshingTimesPerDay = 60 / refreshingTimeInMinutes * 24

            for i in 0 ..< refreshingTimesPerDay {
                let fireDate = startOfTheDay.date.dateByAdding(i * refreshingTimeInMinutes, .minute).date

                let userInput = userInputFromData(nearestBirthdays: nearestBirthdays.shuffled(), otherBirthdays: otherBirthdays, nextBirthday: nextBirthday, header: relevantGroup.name, isBirthdayToday: groupIsBirthdayGroup)

                timelineEntries.append(DateTimelineEntry(date: fireDate, userInput: userInput))
            }

        } else {
            let userInputForWholeDay = userInputFromData(nearestBirthdays: nearestBirthdays, otherBirthdays: otherBirthdays, nextBirthday: nextBirthday, header: relevantGroup.name, isBirthdayToday: groupIsBirthdayGroup)

            timelineEntries.append(DateTimelineEntry(date: startOfTheDay, userInput: userInputForWholeDay))
            timelineEntries.append(DateTimelineEntry(date: endOfTheDay, userInput: userInputForWholeDay))
        }

        return timelineEntries
    }

    public static func createTimelineEntriesForMultiWidget(birthdays: [Birthday]) -> [DateTimelineEntry] {
        var timelineEntries: [DateTimelineEntry] = []
        let startOfTheDay = Date().startOfDay

        let birthdaysToShow = 5
        var nextBirthdays = Array(birthdays.map { BirthdayInfoViewModelMapper.map(birthday: $0, includeImage: false) }.sorted(by: { $0.daysLeftToBirthday < $1.daysLeftToBirthday }).prefix(birthdaysToShow))

        let birthdayNames = createBirthdayNamesStringForMultiWidget(birthdays: nextBirthdays)

        var firstDate: String?
        var lastDate: String?

        if let firstBirthday = nextBirthdays.first {
            firstDate = firstBirthday.birthdayIsToday ? "widget.multi.timeline.today".localize() : ProjectDateFormatter.formatDate(date: firstBirthday.birthdateInYear, showYearIfAvailable: false)
        }

        if nextBirthdays.count > 1, let lastBirthday = nextBirthdays.last {
            lastDate = ProjectDateFormatter.formatDate(date: lastBirthday.birthdateInYear, showYearIfAvailable: false)
        }

        for i in 0 ..< nextBirthdays.count {
            nextBirthdays[i].fetchProfilePic()
        }

        let userInput = UserInput(sortedBirthdays: nextBirthdays, title: birthdayNames, subTitle: "", header: "")
        userInput.additionalInfo1 = firstDate
        userInput.additionalInfo2 = lastDate
        timelineEntries.append(DateTimelineEntry(date: startOfTheDay, userInput: userInput))
        timelineEntries.append(DateTimelineEntry(date: startOfTheDay + 1.days, userInput: userInput))

        return timelineEntries
    }

    public static func createTimelineEntriesForInlineWidget(birthdays: [Birthday]) -> [DateTimelineEntry] {
        var timelineEntries: [DateTimelineEntry] = []
        let startOfTheDay = Date().startOfDay

        // Gruppe laden
        let birthdayViewModels = birthdays.map { BirthdayInfoViewModelMapper.map(birthday: $0, includeImage: false) }
        let groupedBirthdays = BirthdayTimePeriodGroupService.assignBirthdaysToTimePeriodGroup(inputBirthdays: birthdayViewModels, justFirstGroup: true, shorter: true)

        guard let relevantGroup = groupedBirthdays.first else {
            return [DateTimelineEntry(date: Date(), userInput: userInputFromData(nearestBirthdays: [], otherBirthdays: [], nextBirthday: Date(), header: "-"))]
        }

        // Nach Datum sortieren & mischen
        let birthdaysInGroup = relevantGroup.birthdays.shuffled()

        let namesTitle = createContentForInlineWidget(group: relevantGroup, birthdays: birthdaysInGroup)

        let userInput = UserInput(sortedBirthdays: birthdaysInGroup, title: namesTitle, subTitle: "", header: "")
        userInput.birthdayIsToday = relevantGroup.isBirthdayToday
        timelineEntries.append(DateTimelineEntry(date: startOfTheDay, userInput: userInput))
        timelineEntries.append(DateTimelineEntry(date: startOfTheDay + 1.days, userInput: userInput))

        return timelineEntries
    }

    private static func userInputFromData(nearestBirthdays: [BirthdayInfoViewModel], otherBirthdays: [BirthdayInfoViewModel], nextBirthday: Date, header: String, isBirthdayToday: Bool = false) -> UserInput {
        // String aus den relevanten Namen erstellen
        let birthdayNames = createBirthdayNamesString(birthdays: nearestBirthdays)

        let userinput = UserInput(sortedBirthdays: nearestBirthdays + otherBirthdays, title: birthdayNames, subTitle: ProjectDateFormatter.formatDate(date: nextBirthday, showYearIfAvailable: false), header: header)
        userinput.birthdayIsToday = isBirthdayToday
        return userinput
    }

    private static func createBirthdayNamesStringForMultiWidget(birthdays: [BirthdayInfoViewModel]) -> String {
        let maxCharCount = 35
        var titleString = ""

        var namesToAdd = birthdays.map { birthday in
            if birthday.firstName.count == 0 {
                return birthday.lastName
            } else {
                return birthday.firstName
            }
        }
        titleString = namesToAdd.first ?? ""
        namesToAdd = Array(namesToAdd.dropFirst())

        var namesAdded = 0
        for (i, name) in namesToAdd.enumerated() {
            if (titleString.count + name.count + 2) <= maxCharCount {
                let seperator = i == namesToAdd.count - 1 ? " & " : ", "
                titleString += seperator + name
                namesAdded += 1
                continue
            }
            break
        }

        let missingNames = namesToAdd.count - namesAdded

        if missingNames > 0 {
            titleString += " +\(missingNames)"
        }

        return titleString
    }

    private static func createContentForInlineWidget(group: BirthdaysInTimePeriodGroup, birthdays: [BirthdayInfoViewModel]) -> String {
        let maxChars = 21
        let titlePrefix = "\(group.name): "
        let charsLeft = maxChars - titlePrefix.count

        var namesToAdd = birthdays.map { birthday in
            if birthday.firstName.count == 0 {
                return birthday.lastName
            } else {
                return birthday.firstName
            }
        }
        var nameString = namesToAdd.first ?? ""
        namesToAdd = Array(namesToAdd.dropFirst())

        var namesAdded = 0
        for (i, name) in namesToAdd.enumerated() {
            if (nameString.count + name.count + 2) <= charsLeft {
                let seperator = i == namesToAdd.count - 1 ? " & " : ", "
                nameString += seperator + name
                namesAdded += 1
                continue
            }
            break
        }

        let missingNames = namesToAdd.count - namesAdded

        if missingNames > 0 {
            nameString += " +\(missingNames)"
        }

        return titlePrefix + nameString
    }

    private static func createBirthdayNamesString(birthdays: [BirthdayInfoViewModel]) -> String {
        var titleString = ""

        guard let firstBirthday = birthdays.first else {
            return "-"
        }

        let firstName: String = {
            if firstBirthday.firstName.count == 0 {
                return firstBirthday.lastName
            } else {
                return firstBirthday.firstName
            }
        }()

        let secondName: String? = {
            guard let secondBirthday = birthdays[safe: 1] else {
                return nil
            }

            if secondBirthday.firstName.count == 0 {
                return secondBirthday.lastName
            } else {
                return secondBirthday.firstName
            }
        }()

        // Plus anhängen
        titleString = "\(firstName)\(birthdays.count > 1 ? " +\(birthdays.count - 1)" : "")"

        // Sonderfall wenn genau zwei und passend
        if birthdays.count == 2, let secondName {
            let combinedNames = "\(firstName) & \(secondName)"

            if combinedNames.count <= 13 {
                titleString = combinedNames
            }
        }

        return titleString
    }
}
