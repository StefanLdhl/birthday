//
//  NotificationManager.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import Foundation
import SwiftDate
import UserNotifications

class NotificationManager {
    public static func updateAllNotifications() {
        let center = UNUserNotificationCenter.current()

        checkForPromoNotification()

        guard !GroupedUserDefaults.bool(forKey: .localUserInfo_notificationsDeactivated) else {
            return
        }

        // Delete existing standard reminders (except repeating reminders)
        getAllScheduledRemindersForSearchString(searchString: "default") { results, remainingItemsCount in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: results.map { $0.identifier })

            let spacesKeptFree = 7 // Keep places free for subsequent reminders (e.g. via category actions)
            let allowedNotifications = 64 - remainingItemsCount - spacesKeptFree // 64 ist Limit von iOS

            registerCategories(center: center)

            let birthdays = BirthdayRepository.getAllBirthdays().map { BirthdayInfoViewModelMapper.map(birthday: $0) }
            var notifiactionItems: [BirthdayNotificationSetup] = []

            for birthday in birthdays {
                for remider in birthday.group.reminders {
                    let fireDate = DateHelper.combineDateWithTime(date: birthday.birthdateInYear - remider.type.getTimeBeforeDateDateComponents(), time: remider.time, ignoreSeconds: true)

                    notifiactionItems.append(BirthdayNotificationSetup(fireDate: fireDate, birthday: birthday, reminder: remider))
                }
            }

            // Sort notifications by FireDate to cover the most relevant notifications in any case (limit 64)
            notifiactionItems = notifiactionItems.sorted(by: { $0.fireDate < $1.fireDate })

            // Sort out dates in the past and add them back on again
            let nowDate = Date()
            let datesInPast = notifiactionItems.filter { $0.fireDate < nowDate }
            notifiactionItems = notifiactionItems.filter { $0.fireDate > nowDate }
            notifiactionItems.append(contentsOf: datesInPast)

            var notificationsSetCounter = 0
            for notificationItem in notifiactionItems {
                guard notificationsSetCounter < allowedNotifications else {
                    break
                }

                scheduleBirthday(notificationSetup: notificationItem, notificationCenter: center)
                notificationsSetCounter += 1
            }
        }
    }

    private static func checkForPromoNotification() {
        // Delete old promo notifications
        getAllScheduledRemindersForSearchString(searchString: "promoReminderNotification") { results, _ in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: results.map { $0.identifier })
        }

        guard !CurrentUser.isUserPro(), let promoInterval = GroupedUserDefaults.double(forKey: .localUserInfo_promoNotificationReminderDate), promoInterval > Date().timeIntervalSince1970 else {
            GroupedUserDefaults.removeObject(forKey: .localUserInfo_promoNotificationReminderDate)
            return
        }

        // Check whether promo notification is desired and not yet outdated
        guard let salesManagerPromoInterval = GroupedUserDefaults.double(forKey: .widgetStudioDiscounts_currentPromoDeadlineInterval),
              salesManagerPromoInterval > (Date() + 15.minutes).timeIntervalSince1970
        else { return }

        // Set notification 20 minutes before expiry.
        let fireTime = Date(timeIntervalSince1970: salesManagerPromoInterval) - 20.minutes
        let triggerDateComponent = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: fireTime)

        let notificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "app.notification.promoNotification.20minutes.title".localize()
        content.body = "app.notification.promoNotification.20minutes.desc".localize()
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = ["promoTimeInterval": salesManagerPromoInterval]

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: false)

        let identifier = "promoReminderNotification_1_\(salesManagerPromoInterval)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    public static func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // Entfernt alle Reminder für einen Geburtstag inkl. der über den User wiederholt angeforderten
    public static func removeRemindersForId(identifier: String) {
        getAllScheduledRemindersForSearchString(searchString: "\(identifier)") { results, _ in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: results.map { $0.identifier })
        }
    }

    /// Gibt alle NotificationRequest für ein Suchwort zurück und die Anzahl an verbleibenden Benachrichtigungen
    private class func getAllScheduledRemindersForSearchString(searchString: String, completion: @escaping ([UNNotificationRequest], Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in

            var returnValues: [UNNotificationRequest] = []

            for request in requests {
                if request.identifier.contains(searchString) {
                    returnValues.append(request)
                }
            }

            let remainigItemsCount = requests.count - returnValues.count
            completion(returnValues, remainigItemsCount)
        })
    }

    /// Legt automatisiert eine erstmalige Benachrichtung anhand des ReminderTyps (z.B. "EIn Tag vorher") an.
    private static func scheduleBirthday(notificationSetup: BirthdayNotificationSetup, notificationCenter: UNUserNotificationCenter) {
        let birthdayViewModel = notificationSetup.birthday
        let reminderViewModel = notificationSetup.reminder
        let fireDate = notificationSetup.fireDate
        let birthdayId = birthdayViewModel.identifier
        let reminderType = reminderViewModel.type

        let triggerDateComponent = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: fireDate) // Jährlich

        let textToShow = reminderType.localizedNotificationContent(triggerDate: fireDate, birthday: birthdayViewModel.birthdateInYear, name: birthdayViewModel.firstName)

        let content = UNMutableNotificationContent()
        content.title = textToShow.title
        content.body = textToShow.content
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = ["birthdayId": birthdayId, "contactName": birthdayViewModel.firstName, "birthDate": birthdayViewModel.birthdateInYear, "renewedCount": 0]
        content.categoryIdentifier = RenewedNotificationCategory.getMatchingCategoryForReminderType(type: reminderType)?.rawValue ?? ""

        if let soundFile = reminderViewModel.sound.getSourceFileName() {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFile))
        } else {
            content.sound = UNNotificationSound.default
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: true)

        let identifier = "\(birthdayId)_default_\(reminderViewModel.identifier)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    /// Legt manuell eine (erneute) Benachrichtigung an.
    public static func scheduleCustomNotification(contactName: String, birthdayId: String, triggerDate: Date, birthdate: Date, renewedCounter: Int) {
        let notificationContent = getCustomNotificationContent(contactName: contactName, triggerDate: triggerDate, birthdate: birthdate)

        let renewedCount = renewedCounter + 1
        let triggerDateComponent = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: triggerDate)
        let notificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = notificationContent.title
        content.body = notificationContent.content
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = ["birthdayId": birthdayId, "birthDate": birthdate, "renewedCount": renewedCount, "contactName": contactName]
        content.categoryIdentifier = notificationContent.category.rawValue

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: false)

        let identifier = "\(birthdayId)_renewed_\(renewedCount)_\(Int.random(in: 0 ... 999_999))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    /// Erstellt den passenden Content für erneute Benachrichtigungen abhängig von der verbleibenden Zeot zum Geburtstag
    public static func getCustomNotificationContent(contactName: String, triggerDate: Date, birthdate: Date) -> (title: String, content: String, category: RenewedNotificationCategory) {
        let formattedBirthdateString = ProjectDateFormatter.formatDate(date: birthdate, showYearIfAvailable: false)

        var cal = Calendar.current
        cal.timeZone = TimeZone.current

        let isToday = cal.isDate(triggerDate, inSameDayAs: birthdate)
        let isInPast = triggerDate > birthdate && !isToday

        if isInPast {
            let title = "app.notification.upcomingBirthdayText.title.universal.title.belated.%@.%@".localize(values: contactName, formattedBirthdateString)

            let desc = "app.notification.upcomingBirthdayText.content.onBelayedBirthday".localize()
            return (title: "🚩 " + title, content: desc, category: .inPastCategory)
        }

        if isToday {
            let title = "app.notification.upcomingBirthdayText.title.onBirthdate.%@".localize(values: contactName)
            let desc = "app.notification.upcomingBirthdayText.content.onBirthday".localize()
            return (title: "🚩 " + title, content: desc, category: .onBirthdayCategory)
        }

        let isTomorrow = cal.isDate(triggerDate + 1.days, inSameDayAs: birthdate)
        if isTomorrow {
            let title = "app.notification.upcomingBirthdayText.title.daysBefore1.%@".localize(values: contactName)

            let desc = "app.notification.upcomingBirthdayText.content.suffix".localize()
            return (title: "🚩 " + title, content: desc, category: .onDayBeforeCategory)
        }

        let isDayAfterTomorrow = cal.isDate(triggerDate + 2.days, inSameDayAs: birthdate)
        if isDayAfterTomorrow {
            let title = "app.notification.upcomingBirthdayText.title.daysBefore2.%@".localize(values: contactName)
            let desc = "app.notification.upcomingBirthdayText.content.suffix".localize()
            return (title: "🚩 " + title, content: desc, category: .onTwoDaysBeforeCategory)
        }

        let title = "app.notification.upcomingBirthdayText.title.universal.title.upcoming.%@.%@".localize(values: contactName, formattedBirthdateString)

        let desc = "app.notification.upcomingBirthdayText.content.suffix".localize()

        return (title: "🚩 " + title, content: desc, category: .onMultipleDaysBeforeCategory)
    }

    private static func registerCategories(center: UNUserNotificationCenter) {
        let allCategories = RenewedNotificationCategory.allCases.map { $0.asCategory() }
        center.setNotificationCategories(Set(allCategories))
    }
}

enum RenewedNotificationCategory: String, CaseIterable {
    case onBirthdayCategory
    case onDayBeforeCategory
    case onTwoDaysBeforeCategory
    case onMultipleDaysBeforeCategory
    case onOverAWeekBeforeCategory
    case onOverAMonthBeforeCategory
    case inPastCategory
    case none

    private func connectedAction() -> [RenewedNotificationAction] {
        switch self {
        case .onBirthdayCategory:
            return [.celebrateNowAction, .againIn1HourAction, .againBelatedIn1DayAction]

        case .onDayBeforeCategory:
            return [.againIn1HourAction, .againIn1DayAction]

        case .onTwoDaysBeforeCategory:
            return [.againIn1HourAction, .againIn1DayAction, .againOnDayOfBirth]

        case .onMultipleDaysBeforeCategory:
            return [.againIn1HourAction, .againIn1DayAction, .againOnDayBeforeDayOfBirth, .againOnDayOfBirth]

        case .onOverAWeekBeforeCategory:
            return [.againIn1DayAction, .againIn1WeekAction, .againOnDayBeforeDayOfBirth, .againOnDayOfBirth]

        case .onOverAMonthBeforeCategory:
            return [.againIn1DayAction, .againIn1WeekAction, .againOnDayBeforeDayOfBirth, .againOnDayOfBirth]

        case .inPastCategory:
            return [.celebrateBelatedlyAction, .againIn1HourAction]

        case .none:
            return []
        }
    }

    public func asCategory() -> UNNotificationCategory {
        return UNNotificationCategory(identifier: rawValue, actions: connectedAction().map { $0.asNotificationAction() }, intentIdentifiers: [])
    }

    public static func getMatchingCategoryForReminderType(type: ReminderType) -> RenewedNotificationCategory? {
        if [ReminderType.onBirthdate].contains(type) {
            return .onBirthdayCategory
        }

        if [ReminderType.daysBefore1].contains(type) {
            return .onDayBeforeCategory
        }

        if [ReminderType.daysBefore2].contains(type) {
            return .onTwoDaysBeforeCategory
        }

        if [ReminderType.daysBefore3, ReminderType.weeksBefore1].contains(type) {
            return .onMultipleDaysBeforeCategory
        }

        if [ReminderType.weeksBefore2, ReminderType.weeksBefore3, ReminderType.monthsBefore1].contains(type) {
            return .onOverAWeekBeforeCategory
        }

        if [ReminderType.monthsBefore2, ReminderType.monthsBefore3].contains(type) {
            return .onOverAMonthBeforeCategory
        }

        return nil
    }
}

enum RenewedNotificationAction: String {
    case celebrateNowAction
    case againIn1HourAction
    case againIn1DayAction
    case againBelatedIn1DayAction
    case againIn1WeekAction
    case againOnDayOfBirth
    case againOnDayBeforeDayOfBirth
    case celebrateBelatedlyAction

    public func asNotificationAction() -> UNNotificationAction {
        if let options = notificationOptions() {
            return UNNotificationAction(identifier: rawValue, title: localizedTitle(), options: options)

        } else {
            return UNNotificationAction(identifier: rawValue, title: localizedTitle())
        }
    }

    private func notificationOptions() -> UNNotificationActionOptions? {
        if [RenewedNotificationAction.celebrateNowAction, .celebrateBelatedlyAction].contains(self) {
            return .foreground
        }
        return nil
    }

    private func localizedTitle() -> String {
        return "app.notification.renewedNotificationAction.\(rawValue)".localize()
    }
}

public struct BirthdayNotificationSetup {
    var fireDate: Date
    var birthday: BirthdayInfoViewModel
    var reminder: ReminderViewModel
}
