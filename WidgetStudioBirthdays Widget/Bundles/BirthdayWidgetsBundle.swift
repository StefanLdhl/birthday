//
//  BirthdayWidgetsBundle.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

@main
struct BirthdayWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SingleBirthdayWidget()
        MultiBirthdayWidget()
        LockMultiBirthdayWidget()
        LockInlineBirthdayWidget()
    }
}
