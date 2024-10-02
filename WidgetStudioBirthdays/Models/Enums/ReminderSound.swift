//
//  ReminderSound.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import Foundation

enum ReminderSound: String, CaseIterable {
    case defaultSound
    case whistle
    case partyHorn

    public func localizedTitle() -> String {
        return "app.reminderSound.\(rawValue)".localize()
    }
    
    public func getSourceFileName() -> String? {
        
        switch self {
       
        case .defaultSound:
            return nil
        case .whistle:
            return "NotificationSound-Whistle.aiff"
        case .partyHorn:
            return "NotificationSound-Horn.aiff"

        }
    }
}
