//
//  AppDelegate.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import CoreData
import RevenueCat
import UIKit
import WidgetKit
import Zephyr

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        if !GroupedUserDefaults.bool(forKey: .localUserInfo_defaultDataCreated) {
            GroupedUserDefaults.set(value: true, for: .localUserInfo_defaultDataCreated)
            DefaultDataProvider.generateDefaultData()
        }

        PictureRepository.cleanDuplicatePictures()

        if let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            GroupedUserDefaults.set(value: appVersion, for: .localUserInfo_LastBundleVersion)
        }

        if GroupedUserDefaults.date(forKey: .localUserInfo_firstAppStartDate) == nil {
            GroupedUserDefaults.set(value: Date(), for: .localUserInfo_firstAppStartDate)
        }

        syncUserDefaults()
        configureRevenueCat()

        ContactRefechter.refetchContactPictures()

        return true
    }

    private func configureRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: CatConstants.apiKey)
        Purchases.shared.delegate = self
    }

    private func syncUserDefaults() {
        let keysToSync = GUDKey.allCases.filter { $0.shouldBeSynced }.map { $0.rawValue }
        Zephyr.debugEnabled = false
        Zephyr.sync(keys: keysToSync, userDefaults: GroupedUserDefaults.getSelf())
        Zephyr.addKeysToBeMonitored(keys: keysToSync)
        Zephyr.syncUbiquitousKeyValueStoreOnChange = true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // WidgetCenter.shared.reloadAllTimelines() Nicht sinnvoll, da CoreData Änderungen noch nicht lokal umgesetzt
        completionHandler(.newData)
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print(url)

        return true
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completion: @escaping () -> Void)
    {
        NotificationHandler.handleBackgroundNotificationActionFor(response: response)
        completion()
    }

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .sound])
    }

    func applicationWillTerminate(_: UIApplication) {
        NotificationManager.updateAllNotifications()
    }
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let isSubscriber = customerInfo.entitlements[CatConstants.entitlementName]?.isActive ?? false
        let hasLifetime = customerInfo.nonSubscriptions.count > 0

        GroupedUserDefaults.set(value: hasLifetime, for: .localUserInfo_userHasLifetime)
        GroupedUserDefaults.set(value: isSubscriber, for: .localUserInfo_userIsPro)

        GroupedUserDefaults.set(value: customerInfo.firstSeen, for: .localUserInfo_firstSeenOfUser)
    }
}
