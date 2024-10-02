//
//  NotificationManager.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import Foundation
import SwiftDate
import UserNotifications

class NotificationHandler {
    class func handleNotificationTapForNotificationsUserInfo(userInfo:  [String: AnyObject]) {

        sendNotificationToHandleLink(userInfo: userInfo)
    }

    class func handleBackgroundNotificationActionFor(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        // let notificationID = response.notification.request.identifier
        let actionID = response.actionIdentifier

  
        if actionID == UNNotificationDefaultActionIdentifier {
            AppUsageCounter.logEventFor(type: .appOpenedThroughLocalNotification)
            sendNotificationToHandleLink(userInfo: userInfo)
            return
        }

        guard let action = RenewedNotificationAction(rawValue: actionID), let birthDate = userInfo["birthDate"] as? Date, let name = userInfo["contactName"] as? String, let renewedCounter = userInfo["renewedCount"] as? Int, let birthdayId = userInfo["birthdayId"] as? String else {
            return
        }

        if action == .celebrateNowAction || action == .celebrateBelatedlyAction {
            sendNotificationToHandleLink(userInfo: userInfo)
        }

        var newTriggerDate: Date?
        switch action {
        case .againIn1HourAction:
            newTriggerDate = Date() + 1.hours
        case .againIn1DayAction:
            newTriggerDate = Date() + 1.days
        case .againBelatedIn1DayAction:
            newTriggerDate = Date() + 1.days
        case .againIn1WeekAction:
            newTriggerDate = Date() + 1.weeks
        case .againOnDayOfBirth:
            newTriggerDate = birthDate
        case .againOnDayBeforeDayOfBirth:
            newTriggerDate = birthDate - 1.days
        case .celebrateBelatedlyAction:
            newTriggerDate = nil
        case .celebrateNowAction:
            newTriggerDate = nil
        }

        guard let triggerDate = newTriggerDate else {
            return
        }

        NotificationManager.scheduleCustomNotification(contactName: name, birthdayId: birthdayId, triggerDate: triggerDate, birthdate: birthDate, renewedCounter: renewedCounter)
    }
    
    private class func sendNotificationToHandleLink(userInfo: [AnyHashable: Any]) {
        
        GroupedUserDefaults.set(value: userInfo, for: .localUserInfo_storedLocalNotificationInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil, userInfo: userInfo)

    }
}
