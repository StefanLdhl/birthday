//
//  MultiBirthdayWidget.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct MultiBirthdayWidget: Widget {
    let uniqueId: String = "com.stefanliesendahl.MultiBirthdayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: uniqueId, intent: MultiBirthdayWidgetIntent.self, provider: MultiBirthdayProvider()) { entry in
            MultiBirthdayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget.multi.displayName".localize())
        .description("widget.multi.description".localize())
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct MultiBirthdayWidgetEntryView: View {
    var entry: MultiBirthdayProvider.Entry
    var body: some View {
        if entry.userInput.sortedBirthdays.count > 0 {
            MultiBirthdayView(userInput: entry.userInput)
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

struct MultiBirthdayWidgetPreview: PreviewProvider {
    static var previews: some View {
        MultiBirthdayWidgetEntryView(entry: DateTimelineEntry(date: Date(), userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
