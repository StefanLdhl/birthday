//
//  SiriNewBirthdayIntentHandler.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 03.02.21.
//

import Intents

class SiriNewBirthdayIntentHandler: NSObject, SiriNewBirthdayIntentHandling {
    func handle(intent _: SiriNewBirthdayIntent, completion: @escaping (SiriNewBirthdayIntentResponse) -> Void) {
        let response = SiriNewBirthdayIntentResponse(code: .continueInApp, userActivity: nil)
        completion(response)
    }
}
