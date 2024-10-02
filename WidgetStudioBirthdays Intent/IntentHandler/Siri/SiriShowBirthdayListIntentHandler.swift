//
//  SiriShowBirthdayListIntentHandler.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 03.02.21.
//

import Foundation
import Intents

class SiriShowBirthdayListIntentHandler: NSObject, SiriShowBirthdayListIntentHandling {
    func handle(intent _: SiriShowBirthdayListIntent, completion: @escaping (SiriShowBirthdayListIntentResponse) -> Void) {
        let response = SiriShowBirthdayListIntentResponse(code: .continueInApp, userActivity: nil)
        completion(response)
    }
}
