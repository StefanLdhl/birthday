//
//  DeepLinkHandler.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 17.01.21.
//

import Foundation

class DeepLinkHandler {
    static func handleDeepLinkUrl(url: URL?, delay: Double = 0) {
        guard let url = url else { return }

        if url.isFileURL {
            let openEventUserInfo: [String: String] = ["filePath": url.path]

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil, userInfo: openEventUserInfo)
            }
        }

        if let eventUrl = url.valueOf("open") {
            AppUsageCounter.logEventFor(type: .appOpenedThroughWidgetTap)

            let openEventUserInfo: [String: String] = ["birthdayId": eventUrl]

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil, userInfo: openEventUserInfo)
            }
        }

        if url.valueOf("purchase") != nil {
            AppUsageCounter.logEventFor(type: .appOpenedThroughPurchaseRedirection)

            let openEventUserInfo: [String: String] = ["birthdayId": "purchase"]

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil, userInfo: openEventUserInfo)
            }
        }
    }

    static func handleShortcutOrActivity(shortcutIdentifier: String) {
        if shortcutIdentifier == "AddNewAction" {
            AppUsageCounter.logEventFor(type: .newEventThroughHomeScreenShortcut)
            callAppWithUserInfo(userInfo: ["birthdayId": "new"])
        }

        if shortcutIdentifier == "ImportAction" {
            AppUsageCounter.logEventFor(type: .newContactImportThroughHomeScreenShortcut)
            callAppWithUserInfo(userInfo: ["birthdayId": "import"])
        }

        if shortcutIdentifier == "SiriShowBirthdayListIntent" {
            AppUsageCounter.logEventFor(type: .listOpenedThroughSiriShortcut)
            callAppWithUserInfo(userInfo: ["birthdayId": "all"])
        }

        if shortcutIdentifier == "SiriNewBirthdayIntent" {
            AppUsageCounter.logEventFor(type: .newEventThroughSiriShortcut)
            callAppWithUserInfo(userInfo: ["birthdayId": "new"])
        }

        if shortcutIdentifier == "SiriOpenContactImportIntent" {
            AppUsageCounter.logEventFor(type: .newContactImportThroughSiriShortcut)
            callAppWithUserInfo(userInfo: ["birthdayId": "import"])
        }
    }

    private static func callAppWithUserInfo(userInfo: [String: String]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil, userInfo: userInfo)
        }
    }
}
