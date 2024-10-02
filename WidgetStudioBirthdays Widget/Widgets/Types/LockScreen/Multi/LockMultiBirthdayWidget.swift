//
//  LockMultiBirthdayWIdget.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 08.09.22.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct LockMultiBirthdayWidget: Widget {
    let uniqueId: String = "com.stefanliesendahl.LockMultiBirthdayWidget"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return IntentConfiguration(kind: uniqueId, intent: LockMultiBirthdayWidgetIntent.self, provider: LockMultiBirthdayProvider()) { entry in
                LockMultiBirthdayWidgetEntryView(entry: entry)
            }

            .configurationDisplayName("widget.multi.displayName".localize())
            .description("widget.lock.multi.description".localize())
            .supportedFamilies([.accessoryRectangular])
            .contentMarginsDisabled()
        } else {
            return EmptyWidgetConfiguration()
        }
    }
}

struct LockMultiBirthdayWidgetEntryView: View {
    var entry: LockMultiBirthdayProvider.Entry
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            if entry.userInput.sortedBirthdays.count > 0 {
                let widgetIdentifierToOpen = getWidgetBirthdayIdentifier(birthdays: entry.userInput.sortedBirthdays)
                LockMultiBirthdayRectangleView(userInput: entry.userInput)
                    .widgetURL(URL(string: "widgetstudiobirthdays://?open=\(widgetIdentifierToOpen)"))

            } else {
                LockMultiEmptyBirthdayRectangleView()
            }

        } else {
            Text("-")
        }
    }

    private func getWidgetBirthdayIdentifier(birthdays: [BirthdayInfoViewModel]) -> String {
        if birthdays.count == 1, let first = birthdays.first {
            return first.identifier
        }

        if let first = birthdays.first, first.birthdayIsToday {
            return first.identifier
        }

        return "all"
    }
}

struct LockMultiBirthdayWidgetPreview: PreviewProvider {
    static var previews: some View {
        LockMultiBirthdayWidgetEntryView(entry: DateTimelineEntry(date: Date(), userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
