//
//  SceneDelegate.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        if let url = connectionOptions.urlContexts.first?.url {
            DeepLinkHandler.handleDeepLinkUrl(url: url, delay: 0.5)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            DeepLinkHandler.handleShortcutOrActivity(shortcutIdentifier: shortcutItem.type)
        }

        if let userActvity = connectionOptions.userActivities.first {
            DeepLinkHandler.handleShortcutOrActivity(shortcutIdentifier: userActvity.activityType)
        }
    }

    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        DeepLinkHandler.handleShortcutOrActivity(shortcutIdentifier: userActivity.activityType)
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_: UIScene) {
        NotificationManager.updateAllNotifications()
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        DeepLinkHandler.handleDeepLinkUrl(url: URLContexts.first?.url)
    }

    func windowScene(_: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler _: @escaping (Bool) -> Void) {
        DeepLinkHandler.handleShortcutOrActivity(shortcutIdentifier: shortcutItem.type)
    }
}
