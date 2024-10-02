//
//  SingleBirthdayWidget.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct SingleBirthdayWidget: Widget {
    let uniqueId: String = "com.stefanliesendahl.SingleBirthdayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: uniqueId, intent: SingleBirthdayWidgetIntent.self, provider: SingleBirthdayProvider()) { entry in
            SingleBirthdayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget.single.displayName".localize())
        .description("widget.single.description".localize())
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct SingleBirthdayWidgetEntryView: View {
    var entry: SingleBirthdayProvider.Entry
    var body: some View {
        if entry.userInput.sortedBirthdays.count > 0 {
            let widgetIdentifierToOpen = getWidgetBirthdayIdentifier(birthdays: entry.userInput.sortedBirthdays)
            SingleBirthdayView(userInput: entry.userInput)
                .widgetURL(URL(string: "widgetstudiobirthdays://?open=\(widgetIdentifierToOpen)"))
        } else {
            EmptySingleBirthdayView()
        }
    }

    private func getWidgetBirthdayIdentifier(birthdays: [BirthdayInfoViewModel]) -> String {
        if birthdays.count == 1, let first = birthdays.first {
            return first.identifier
        }

        return "all"
    }
}

struct SingleDateWidgetPreview: PreviewProvider {
    static var previews: some View {
        SingleBirthdayWidgetEntryView(entry: DateTimelineEntry(date: Date(), userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
