//
//  CurrentUser.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 10.01.21.
//

import Foundation
import SwiftDate

class CurrentUser {
    static func isUserPro() -> Bool {
        var userIsPro = GroupedUserDefaults.bool(forKey: .localUserInfo_userIsPro)

        if !userIsPro, Config.appConfiguration == .TestFlight, let endDate = GroupedUserDefaults.date(forKey: .TestFlightFreeTrialEndTime3), endDate > Date() {
            userIsPro = true
        }

        if !userIsPro && GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated) {
            GroupedUserDefaults.set(value: false, for: .localUserInfo_iCloudActivated)
            CoreDataStack.defaultStack.reinitializePersistentCloudKitContainer()
        }

        return userIsPro
    }

    static func userHasLifetimeAccess() -> Bool {
        return GroupedUserDefaults.bool(forKey: .localUserInfo_userHasLifetime)
    }

    static func isEarlyAdopter() -> Bool {
        if GroupedUserDefaults.bool(forKey: .crossDeviceUserInfo_isEarlyAdopter) {
            return true
        }

        var isEarlyAdopter = false
        let isEarlyAdopterTimeIntervalBound = 1_625_246_588.0 // 02.07.21, 19 Uhr

        if let firstSeenRc = GroupedUserDefaults.date(forKey: .localUserInfo_firstSeenOfUser), firstSeenRc.timeIntervalSince1970 < isEarlyAdopterTimeIntervalBound {
            isEarlyAdopter = true
        } else if let firstSeenApp = GroupedUserDefaults.date(forKey: .localUserInfo_firstAppStartDate), firstSeenApp.timeIntervalSince1970 < isEarlyAdopterTimeIntervalBound {
            isEarlyAdopter = true
        }

        if isEarlyAdopter {
            GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_isEarlyAdopter)
        }

        return isEarlyAdopter
    }

    static func firstSeenDate() -> Date? {
        return GroupedUserDefaults.date(forKey: .localUserInfo_firstSeenOfUser)
    }

    static func isEligibleForOtherAppPromo() -> Bool {
        return false
        // return !hasBoughtOtherApp() && (AppUsageCounter.getLogCountFor(type: .newBirthday) > 1 || AppUsageCounter.getLogCountFor(type: .contactImport) > 0)
    }
}
