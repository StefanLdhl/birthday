//
//  AppAnalytics.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation

class AppUsageCounter {
    /// Loggt ein Analytics Event
    class func logEventFor(type: AppUsageCounterEvent) {
        let key = getUserDefaultKey(event: type)
        let oldValue = GroupedUserDefaults.integer(forKey: key)
        GroupedUserDefaults.set(value: oldValue + 1, for: key)
    }

    /// Setzt einen expliziten Wert für ein Analytics Event
    class func setValueManually(type: AppUsageCounterEvent, value: Int) {
        let key = getUserDefaultKey(event: type)
        GroupedUserDefaults.set(value: value, for: key)
    }

    /// Gibt den aktuellen Wert eines Analytic Events zurück
    class func getLogCountFor(type: AppUsageCounterEvent) -> Int {
        let key = getUserDefaultKey(event: type)
        return GroupedUserDefaults.integer(forKey: key)
    }

    /// Erstellt den entsprechenden UserDefault Key
    private class func getUserDefaultKey(event: AppUsageCounterEvent) -> GUDKey {
        return event.userDefaultKey
    }

    public class func resetAll() {
        for event in AppUsageCounterEvent.allCases {
            setValueManually(type: event, value: 0)
        }
    }
}

public enum AppUsageCounterEvent: String, CaseIterable {
    case newBirthday
    case contactImport
    case fileImport
    case editViewOpened
    case newMessageTemplate
    case appStoreReview
    case appOpenedThroughPurchaseRedirection
    case appOpenedThroughWidgetTap
    case appOpenedThroughLocalNotification
    case newEventThroughHomeScreenShortcut
    case newContactImportThroughHomeScreenShortcut
    case newEventThroughSiriShortcut
    case listOpenedThroughSiriShortcut
    case newContactImportThroughSiriShortcut
    case twitterInterest
    case instaInterest
    case purchaseScreenOpened
    case privacyPolicyOpened

    var userDefaultKey: GUDKey {
        switch self {
        case .newBirthday:
            return .appAnalytics_newBirthday
        case .contactImport:
            return .appAnalytics_contactImport
        case .fileImport:
            return .appAnalytics_fileImport
        case .editViewOpened:
            return .appAnalytics_editViewOpened
        case .newMessageTemplate:
            return .appAnalytics_newMessageTemplate
        case .appStoreReview:
            return .appAnalytics_appStoreReview
        case .appOpenedThroughPurchaseRedirection:
            return .appAnalytics_appOpenedThroughPurchaseRedirection
        case .appOpenedThroughWidgetTap:
            return .appAnalytics_appOpenedThroughWidgetTap
        case .appOpenedThroughLocalNotification:
            return .appAnalytics_appOpenedThroughLocalNotification
        case .newEventThroughHomeScreenShortcut:
            return .appAnalytics_newEventThroughHomeScreenShortcut
        case .newContactImportThroughHomeScreenShortcut:
            return .appAnalytics_newContactImportThroughHomeScreenShortcut
        case .newEventThroughSiriShortcut:
            return .appAnalytics_newEventThroughSiriShortcut
        case .listOpenedThroughSiriShortcut:
            return .appAnalytics_listOpenedThroughSiriShortcut
        case .newContactImportThroughSiriShortcut:
            return .appAnalytics_newContactImportThroughSiriShortcut
        case .twitterInterest:
            return .appAnalytics_twitterInterest
        case .instaInterest:
            return .appAnalytics_instaInterest
        case .purchaseScreenOpened:
            return .appAnalytics_purchaseScreenOpened
        case .privacyPolicyOpened:
            return .appAnalytics_privacyPolicyOpened
        }
    }
}
