//
//  LockInlineBirthdayWidget.swift
//  WidgetStudioBirthdays WidgetExtension
//
//  Created by Stefan Liesendahl on 09.09.22.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct LockInlineBirthdayWidget: Widget {
    let uniqueId: String = "com.stefanliesendahl.LockInlineBirthdayWidget"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return IntentConfiguration(kind: uniqueId, intent: LockInlineBirthdayWidgetIntent.self, provider: LockInlineBirthdayProvider()) { entry in
                LockInlineBirthdayWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("widget.inline.displayName".localize())
            .description("widget.inline.description".localize())
            .supportedFamilies([.accessoryInline])
            .contentMarginsDisabled()
        } else {
            return EmptyWidgetConfiguration()
        }
    }
}

struct LockInlineBirthdayWidgetEntryView: View {
    var entry: LockInlineBirthdayProvider.Entry
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            let widgetIdentifierToOpen = getWidgetBirthdayIdentifier(birthdays: entry.userInput.sortedBirthdays)
            LockBirthdayInlineView(userInput: entry.userInput)
                .widgetURL(URL(string: "widgetstudiobirthdays://?open=\(widgetIdentifierToOpen)"))

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

struct LockInlineBirthdayWidgetPreview: PreviewProvider {
    static var previews: some View {
        LockInlineBirthdayWidgetEntryView(entry: DateTimelineEntry(date: Date(), userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
