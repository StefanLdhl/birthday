//
//  GroupedUserDefaults.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation

class GroupedUserDefaults {
    private static let appGroupId = "group.stefanliesendahl.widgetstudio.birthdayevents"

    static func set(value: Any?, for key: GUDKey) {
        UserDefaults(suiteName: appGroupId)!.set(value, forKey: key.rawValue)
        UserDefaults(suiteName: appGroupId)!.synchronize()
    }

    static func value(forKey: GUDKey) -> Any? {
        return UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue)
    }

    static func synchronize() {
        UserDefaults(suiteName: appGroupId)!.synchronize()
    }

    static func double(forKey: GUDKey) -> Double? {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? Double {
            return result
        }

        return nil
    }

    static func integer(forKey: GUDKey) -> Int {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? Int {
            return result
        }

        return 0
    }

    static func bool(forKey: GUDKey) -> Bool {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? Bool {
            return result
        }

        return false
    }

    static func string(forKey: GUDKey) -> String? {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? String {
            return result
        }

        return nil
    }

    static func dictionary(forKey: GUDKey) -> NSDictionary? {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? NSDictionary {
            return result
        }

        return nil
    }

    static func array(forKey: GUDKey) -> NSArray? {
        if let result = UserDefaults(suiteName: appGroupId)!.value(forKey: forKey.rawValue) as? NSArray {
            return result
        }

        return nil
    }

    static func date(forKey: GUDKey) -> Date? {
        if let result = UserDefaults(suiteName: appGroupId)!.object(forKey: forKey.rawValue) as? Date {
            return result
        }

        return nil
    }

    static func data(forKey: GUDKey) -> Data? {
        if let result = UserDefaults(suiteName: appGroupId)!.data(forKey: forKey.rawValue) {
            return result
        }

        return nil
    }

    static func removeObject(forKey: GUDKey) {
        UserDefaults(suiteName: appGroupId)!.removeObject(forKey: forKey.rawValue)
        UserDefaults(suiteName: appGroupId)!.synchronize()
    }

    static func getAllKeysForSynchronisation() -> [String] {
        let allKeys = Array(UserDefaults(suiteName: appGroupId)!.dictionaryRepresentation().keys.map { $0 })
        return allKeys.filter { $0.hasPrefix("crossDeviceUserInfo_") }
    }

    static func getSelf() -> UserDefaults {
        return UserDefaults(suiteName: appGroupId)!
    }
}

public enum GUDKey: String, CaseIterable {
    case localUserInfo_defaultDataCreated
    case localUserInfo_LastBundleVersion
    case localUserInfo_firstAppStartDate
    case localUserInfo_userHasLifetime
    case localUserInfo_userIsPro
    case localUserInfo_firstSeenOfUser
    case TestFlightFreeTrialEndTime3
    case localUserInfo_iCloudActivated
    case crossDeviceUserInfo_isEarlyAdopter
    case localUserInfo_nameFormatShowLastNameFirst
    case crossDeviceUserInfo_customDateFormattingId
    case localUserInfo_notificationsDeactivated
    case localUserInfo_promoNotificationReminderDate
    case widgetStudioDiscounts_currentPromoDeadlineInterval
    case localUserInfo_backgroundStyleId
    case localUserInfo_storedLocalNotificationInfo
    case allPlansPromoHidden
    case localUserInfo_lastAllPlansShownDate
    case widgetStudioDiscounts_allPromoCount
    case widgetStudioDiscounts_lastPromoDeadlineInterval
    case crossDeviceUserInfo_userWroteReview
    case localUserInfo_usersLastStarRating
    case crossDeviceUserInfo_ownName
    case localUserInfo_quickActionPrivacyInfoShown
    case crossDeviceUserInfo_quickActionOrder
    case localUserInfo_sortingId
    case localUserInfo_lastConfettiPartyOnList
    case localUserInfo_newUserPurchaseOfferShown
    case localUserInfo_lastPromoDate
    case crossDeviceUserInfo_newYearsPromo_reviewAlertDismissed
    case crossDeviceUserInfo_askedForRating
    case localUserInfo_askedForRatingCheck
    case localUserInfo_askedForNotification

    case appAnalytics_newBirthday
    case appAnalytics_contactImport
    case appAnalytics_fileImport
    case appAnalytics_editViewOpened
    case appAnalytics_newMessageTemplate
    case appAnalytics_appStoreReview
    case appAnalytics_appOpenedThroughPurchaseRedirection
    case appAnalytics_appOpenedThroughWidgetTap
    case appAnalytics_appOpenedThroughLocalNotification
    case appAnalytics_newEventThroughHomeScreenShortcut
    case appAnalytics_newContactImportThroughHomeScreenShortcut
    case appAnalytics_newEventThroughSiriShortcut
    case appAnalytics_listOpenedThroughSiriShortcut
    case appAnalytics_newContactImportThroughSiriShortcut
    case appAnalytics_twitterInterest
    case appAnalytics_instaInterest
    case appAnalytics_purchaseScreenOpened
    case appAnalytics_privacyPolicyOpened
    var shouldBeSynced: Bool {
        rawValue.starts(with: "crossDeviceUserInfo_")
    }
}
