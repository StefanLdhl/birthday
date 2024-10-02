//
//  Locale+PreferredLanguage.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 29.11.20.
//

import Foundation

extension Locale {
    static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
