//
//  IntentHandler.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is SingleBirthdayWidgetIntent {
            return SingleBirthdayWidgetIntentHandler()
        } else if intent is MultiBirthdayWidgetIntent {
            return MultiBirthdayWidgetIntentHandler()
        } else if intent is SiriShowBirthdayListIntent {
            return SiriShowBirthdayListIntentHandler()
        } else if intent is SiriNewBirthdayIntent {
            return SiriNewBirthdayIntentHandler()
        } else if intent is SiriOpenContactImportIntent {
            return SiriOpenContactImportIntentHandler()
        } else if intent is LockMultiBirthdayWidgetIntent {
            return LockMultiBirthdayWidgetIntentHandler()
        } else if intent is LockInlineBirthdayWidgetIntent {
            return LockInlineBirthdayWidgetIntentHandler()
        }

        return self
    }
}
