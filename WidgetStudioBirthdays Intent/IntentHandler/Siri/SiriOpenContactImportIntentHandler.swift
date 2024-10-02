//
//  SiriOpenContactImportIntentHandler.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 03.02.21.
//

import Intents

class SiriOpenContactImportIntentHandler: NSObject, SiriOpenContactImportIntentHandling {
    func handle(intent _: SiriOpenContactImportIntent, completion: @escaping (SiriOpenContactImportIntentResponse) -> Void) {
        let response = SiriOpenContactImportIntentResponse(code: .continueInApp, userActivity: nil)
        completion(response)
    }
}
