//
//  QuickActionManager.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import UIKit

class QuickActionManager {
    static func getUsersQuickActions() -> [QuickAction] {
        if let quickActionString = GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_quickActionOrder) {
            return getActionsFromString(actionString: quickActionString)
        }

        return getDefaultOrder()
    }

    static func saveUsersQuickActions(actions: [QuickAction]) {
        let quickActionString = actions.map { $0.rawValue }.joined(separator: ",")
        GroupedUserDefaults.set(value: quickActionString, for: .crossDeviceUserInfo_quickActionOrder)
    }

    public static func getDefaultOrder() -> [QuickAction] {
        return [.phone, .mail, .message, .telegram, .threema, .whatsapp, .otherApps]
    }

    private static func getActionsFromString(actionString: String) -> [QuickAction] {
        var quickActions: [QuickAction] = []
        let items = actionString.components(separatedBy: ",")
        for item in items {
            if let quickAction = QuickAction(rawValue: item) {
                quickActions.append(quickAction)
            }
        }

        //let missingItems = getDefaultOrder().filter { !quickActions.contains($0) }
        //quickActions.append(contentsOf: missingItems)

        return quickActions
    }
}

enum QuickAction: String {
    case phone
    case mail
    case message
    case telegram
    case whatsapp
    case threema
    case otherApps

    public func localizedTitle() -> String {
        return "app.quickAction.\(rawValue)".localize()
    }

    public func icon() -> UIImage {
        var image: UIImage?

        switch self {
        case .phone:
            
            image = UIImage(systemName: "phone.fill")

        case .mail:
            image = UIImage(systemName: "envelope.fill")


        case .message:
            image = UIImage(systemName: "message.fill")


        case .telegram:
            image = UIImage(systemName: "paperplane.circle.fill")

            
        case .threema:
            image = UIImage(systemName: "bubble.left.fill")


        case .whatsapp:
            image = UIImage(systemName: "phone.circle.fill")


        case .otherApps:
            image = UIImage(systemName: "square.and.arrow.up.fill")

        }

        return image ?? UIImage()
    }

    public func additionalInfo() -> String? {
        return nil
    }
}
